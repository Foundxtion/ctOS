import os

def create_config():
    config = {}
    config["authorizedKey"] = __search_pub_key()
    config["network"] = __fill_network_attributes()
    config["services"] = __fill_services_attributes()
    return config

def __select_pub_key(L: list[str]):
    return [file for file in L if file.find(".pub", len(file) - 4) != -1]

def __search_pub_key():
    path = str(os.getenv("HOME")) + "/.ssh"
    L = os.listdir(path)
    L = __select_pub_key(L)

    pub_key_path = path + "/" + L[0]
    with open(pub_key_path, "r") as file:
        print("the pub key found at: " + pub_key_path + " has been loaded as authorized key for ssh")
        return "".join(file.readlines()).removesuffix("\n")


def __fill_network_attributes():
    network = {}
    network["ipAddress"] = input("Please provide an IPv4 address: ")
    prefix = -1
    while prefix <= -1:
        buffer = input("Please provide a valid prefix length of the subnet: ")
        try:
            prefix = int(buffer)
        except:
            prefix = -1
    network["prefixLength"] = prefix
    network["defaultGateway"] = input("Please provide a default IPv4 gateway: ")

    return network

def __fill_openssh_attributes():
    openssh = {}
    permitRootLogin = input("Do you want to enable root login through ssh ? (y/n)")
    openssh["permitRootLogin"] = permitRootLogin == "y" or permitRootLogin == "y\n"

    return openssh

def __fill_services_attributes():
    services = {}
    services["openssh"] = __fill_openssh_attributes()

    return services
