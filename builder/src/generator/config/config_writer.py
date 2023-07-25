def write_config(path, config):
    with open(path, "w+") as file:
        __write_prelude_comments(file)
        __write_config(file, config, 1)
        file.write("}")

def __write_config(file, data, padding):
    tabs = "  " * padding
    if (isinstance(data, bool)):
        file.write(str(data).lower())
        return False
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

def __write_prelude_comments(file):
    file.write("# Foundation-builder generated files: \n")
    file.write("## This file contains secrets that will be used\n")
    file.write("## upon installation and runtime of your custom NixOS\n")
    file.write("## on your machine. Feel free to adjust secrets :D\n")
    file.write("\n")
