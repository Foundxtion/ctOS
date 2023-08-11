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
        print("The pub key found at: " + pub_key_path + " has been loaded as authorized key for ssh.")
        return "".join(file.readlines()).removesuffix("\n")


def __fill_network_attributes():
    network = {}
    network["hasStaticAddress"] = __input_bool("Enable static ip address ?")

    if not network["hasStaticAddress"]:
        network["ipAddress"] = ""
        network["prefixLength"] = 0
        network["defaultGateway"] = ""
        return network

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
    openssh["enable"] = __input_bool("Enable openssh ?")
    openssh["permitRootLogin"] = openssh["enable"] and __input_bool("Enable root login through ssh ?")
    return openssh

def __fill_nginx_attributes():
    nginx = {}
    nginx["enable"] = __input_bool("Enable nginx ?")
    nginx["virtualHosts"] = {}

    return nginx

def __fill_ddclient_attributes():
    ddclient = {
        "enable" : False,
        "protocol" : "",
        "web" : "",
        "username" : "",
        "password" : "",
        "server" : "",
        "domain" : "",
    }

    ddclient["enable"] = __input_bool("Enable ddclient ?")
    if not ddclient["enable"]:
        return ddclient

    ddclient["protocol"] = input("Please provide a protocol: ")
    ddclient["web"] = input("Please provide a web config: ")
    ddclient["username"] = input("Please provide a username: ")
    ddclient["password"] = input("Please provide a password: ")
    ddclient["server"] = input("Please provide a server: ")
    ddclient["domain"] = input("Please provide a domain: ")

    return ddclient


def __fill_services_attributes():
    services = {}
    services["openssh"] = __fill_openssh_attributes()
    services["nginx"] = __fill_nginx_attributes()
    services["ddclient"] = __fill_ddclient_attributes()

    return services

def __input_bool(string):
    ans = input(string + "(y/n): ").strip(" \n")
    return ans == "y"
