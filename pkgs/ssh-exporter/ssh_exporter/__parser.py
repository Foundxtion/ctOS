from dataclasses import dataclass


@dataclass
class Metadata:
    date: str
    status: str
    ip_address: str


def parse_file(timestamp: str, message: str) -> Metadata | None:
    allowed_status = ["invalid", "accepted"]

    status: str = message.strip().split(sep=" ")[0]
    search_ip: list[str] = message.strip().split(sep="from ")

    if len(search_ip) == 1 or status.lower() not in allowed_status:
        return None

    ip_address: str = search_ip[1].strip().split(sep=" ")[0]
    # print(ip_address)
    return Metadata(timestamp, status, ip_address)
