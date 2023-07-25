import os
import shutil
from src.generator.config import create_config, write_config

def print_infos():
    with open("src/generator/foundation.txt", "r") as file:
        foundation = "".join(file.readlines())
    print(foundation)
    print("Welcome to foundation-builder")

def main():
    try:
        os.mkdir("foundation-gen-files")
    except:
        print("a generated file already exist. Exiting.")
        return
    print_infos()
    config = create_config()
    write_config("foundation-gen-files/secrets.nix", config)
    shutil.copy("./src/iso/iso.nix", "foundation-gen-files")

if __name__ == "__main__":
    main()
