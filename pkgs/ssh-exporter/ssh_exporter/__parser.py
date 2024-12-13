from dataclasses import dataclass


@dataclass
class Metadata:
    date: int
    status: str
    ip_address: str


def parse_file(timestamp: int, message: str) -> Metadata | None:
    allowed_status = ["invalid", "accepted", "unable", "banner"]

    status: str = message.strip().split(sep=" ")[0]
    search_ip_from: list[str] = message.strip().split(sep="from ")
    search_ip_with: list[str] = message.strip().split("with ")

    search_ip: list[str] = (
        search_ip_from if len(search_ip_from) >= 2 else search_ip_with
    )

    if len(search_ip) == 1 or status.lower() not in allowed_status:
        return None

    ip_address: str = search_ip[1].strip().split(sep=" ")[0]
    # print(ip_address)
    return Metadata(timestamp, "Accepted" if status.lower() == "accepted" else "Invalid", ip_address)
