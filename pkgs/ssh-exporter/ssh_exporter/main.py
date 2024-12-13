import os
from ssh_exporter import Metadata, parse_file, create_engine, export_metadata

from cysystemd.reader import JournalReader, JournalOpenMode, Rule
from sqlalchemy.engine import Engine
import pandas as pd


def create_reader(service_name: str) -> JournalReader:
    rules = Rule("_SYSTEMD_UNIT", service_name)

    ssh_reader = JournalReader()
    ssh_reader.open(JournalOpenMode.SYSTEM)
    ssh_reader.add_filter(rules)
    ssh_reader.seek_tail()
    ssh_reader.previous()

    return ssh_reader


def get_dataframe(metadatas: list[Metadata]) -> pd.DataFrame:
    date, status, ip_address = [], [], []

    for m in metadatas:
        date.append(m.date)
        status.append(m.status)
        ip_address.append(m.ip_address)

    df_data = {"date": date, "status": status, "ip_address": ip_address}

    df = pd.DataFrame(df_data)
    df["date"] = pd.to_datetime(df["date"], unit="s")

    return df


def process_record(
    reader: JournalReader, engine: Engine, metadatas: list[Metadata], start_index: int
) -> int:
    for record in reader:
        timestamp: int = int(int(record.data["_SOURCE_REALTIME_TIMESTAMP"]) // 1e6)
        message: str = record.data["MESSAGE"]

        m: Metadata | None = parse_file(timestamp, message)
        if m is None:
            continue

        print(m)
        metadatas.append(m)
        start_index += 1

        if len(metadatas) == 5:
            df: pd.DataFrame = get_dataframe(metadatas)
            export_metadata(engine, df, "ssh", start_index)
            metadatas.clear()
    return start_index


def main(username: str, password: str, host: str, port: str, dbname: str) -> None:
    ssh_reader: JournalReader = create_reader("sshd.service")
    engine: Engine = create_engine(username, password, host, port, dbname)
    poll_timeout = 255

    metadatas: list[Metadata] = []
    start_index = 0
    while True:
        ssh_reader.wait(poll_timeout)
        start_index = process_record(ssh_reader, engine, metadatas, start_index)


if __name__ == "__main__":
    username: str = os.getenv("DB_USER", "admin")
    password: str = os.getenv("DB_PASSWORD", "admin123")
    host: str = os.getenv("DB_HOST", "localhost")
    port: str = os.getenv("DB_PORT", "5432")
    dbname: str = os.getenv("DB_NAME", "timeseries")
    main(username, password, host, port, dbname)
