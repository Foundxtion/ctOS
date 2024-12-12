from ssh_exporter import Metadata, parse_file

from cysystemd.reader import JournalReader, JournalOpenMode, Rule

def main() -> None:
    rules = (
        Rule("_SYSTEMD_UNIT", "sshd.service") |
        Rule("_SYSTEMD_UNIT", "ssh.service")
    )

    ssh_reader = JournalReader()
    ssh_reader.open(JournalOpenMode.SYSTEM)
    ssh_reader.add_filter(rules)
    ssh_reader.seek_tail()
    ssh_reader.previous()

    poll_timeout = 255
    while True:
        ssh_reader.wait(poll_timeout)

        for record in ssh_reader:
            timestamp: str = record.data["_SOURCE_REALTIME_TIMESTAMP"]
            message: str = record.data["MESSAGE"]

            m: Metadata = parse_file(timestamp, message)

            print(m)




if __name__ == "__main__":
    main()
