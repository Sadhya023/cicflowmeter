import csv
import json
import logging
from decimal import Decimal
from typing import Protocol

import requests


class OutputWriter(Protocol):
    def write(self, data: dict) -> None:
        raise NotImplementedError


class CSVWriter(OutputWriter):
    def __init__(self, output_file) -> None:
        self.file = open(output_file, "w")
        self.line = 0
        self.writer = csv.writer(self.file)

    def write(self, data: dict) -> None:
        if self.line == 0:
            self.writer.writerow(data.keys())

        self.writer.writerow(data.values())
        self.file.flush()
        self.line += 1

    def __del__(self):
        self.file.close()


class HttpWriter(OutputWriter):
    def __init__(self, output_url) -> None:
        self.url = output_url
        self.session = requests.Session()
        self.logger = logging.getLogger(__name__)

    def _convert_decimals(self, obj):
        """Convert Decimal objects to float for JSON serialization"""
        if isinstance(obj, dict):
            return {key: self._convert_decimals(value) for key, value in obj.items()}
        elif isinstance(obj, list):
            return [self._convert_decimals(item) for item in obj]
        elif isinstance(obj, Decimal):
            return float(obj)
        else:
            return obj

    def write(self, data):
        try:
            # Convert Decimal objects to float for JSON serialization
            clean_data = self._convert_decimals(data)
            resp = self.session.post(self.url, json=clean_data, timeout=5)
            resp.raise_for_status()  # raise if not 2xx
            self.logger.debug(f"Successfully posted flow data to {self.url}")
        except Exception as e:
            self.logger.error(f"HTTPWriter failed posting flow to {self.url}: {e}")

    def __del__(self):
        self.session.close()


def output_writer_factory(output_mode, output) -> OutputWriter:
    match output_mode:
        case "url":
            return HttpWriter(output)
        case "csv":
            return CSVWriter(output)
        case _:
            raise RuntimeError("no output_mode provided")
