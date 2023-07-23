import os
import shutil

def print_infos():
    with open("src/generator/foundation.txt", "r") as file:
        foundation = "".join(file.readlines())
    print(foundation)
    print("Welcome to foundation-builder")

def create_config():
    config = {}
    config["authorizedKey"] = input("Please provide a valid public ssh key: ")
    config["network"] = {}
    config["network"]["ipAddress"] = input("Please provide an IPv4 address: ")
    config["network"]["prefixLength"] = int(input("Please provide the prefix length of the subnet: "))
    config["network"]["defaultGateway"] = input("Please provide a default IPv4 Gateway: ")

    config["caca"] = {}
    config["caca"]["prout"] = "pipi";

    return config

def __write_config(file, data, padding):
    tabs = "\t" * padding
    if (isinstance(data, int)):
        file.write(str(data))
        return False
    if (isinstance(data, str)):
        file.write("\"" + data + "\"")
        return False

    file.write("{\n")
    for key in data:
        file.write(tabs + key + " = ")
        if (__write_config(file, data[key], padding + 1)):
            file.write(tabs + "}")
        file.write(";\n")
    return True


def write_config(path, config):
    with open(path, "w+") as file:
        __write_config(file, config, 1)
        file.write("}")


def main():
    os.mkdir("foundation-gen-files")
    print_infos()
    config = create_config()
    write_config("foundation-gen-files/builder-secrets.nix", config)
    shutil.copy("./src/iso/iso.nix", "foundation-gen-files")

if __name__ == "__main__":
    main()
