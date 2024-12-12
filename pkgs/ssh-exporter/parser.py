import pandas as pd

from dataclasses import dataclass


@dataclass
class Metadata:
    date: str
    status: str
    ip_address: str


def parse_file(filepath: str) -> list[Metadata]:
    allowed_status = ["invalid", "accepted"]
    metadatas: list[Metadata] = []

    with open(filepath, "r") as f:
        lines = f.readlines()

        for line in lines:
            split: list[str] = line.strip().split(sep=": ")
            prefix, suffix = split[0], split[1]

            date: str = prefix.strip().split(sep=" ")[0]
            # print(suffix)

            status: str = suffix.strip().split(sep=" ")[0]
            search_ip: list[str] = suffix.strip().split(sep="from ")

            if len(search_ip) == 1 or status.lower() not in allowed_status:
                continue

            ip_address: str = search_ip[1].strip().split(sep=" ")[0]
            # print(ip_address)
            metadatas.append(Metadata(date, status, ip_address))
    return metadatas


def get_dataframe(metadatas: list[Metadata]) -> pd.DataFrame:
    date, status, ip_address = [], [], []

    for m in metadatas:
        date.append(m.date)
        status.append(m.status)
        ip_address.append(m.ip_address)

    df_data = {"date": date, "status": status, "ip_address": ip_address}

    df = pd.DataFrame(df_data)
    df["date"] = pd.to_datetime(df["date"])

    return df


def main(filepath: str) -> None:
    metadatas = parse_file(filepath)
    df = get_dataframe(metadatas)

    print(df)

    nb_invalid = df[df["status"] == "Invalid"].shape[0]
    nb_accepted = df[df["status"] == "Accepted"].shape[0]

    print(f"nb invalid: {nb_invalid}")
    print(f"nb accepted: {nb_accepted}")

    most_contacted_ip = df\
        .groupby(["ip_address"])\
        .agg({"ip_address": ["count"]})
    most_contacted_ip.columns = most_contacted_ip.columns.droplevel()

    most_contacted_ip = most_contacted_ip.sort_values("count")

    print(most_contacted_ip.columns)
    print(most_contacted_ip)


if __name__ == "__main__":
    main("logs.txt")
