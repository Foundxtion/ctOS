def write_config(path, config):
    with open(path, "w+") as file:
        __write_config(file, config, 1)
        file.write("}")

def __write_config(file, data, padding):
    tabs = "\t" * padding
    if (isinstance(data, int)):
        file.write(str(data))
        return False
    if (isinstance(data, str)):
        file.write("\"" + data + "\"")
        return False
    if (isinstance(data, bool)):
        file.write(str(data).lower())
        return False

    file.write("{\n")
    for key in data:
        file.write(tabs + key + " = ")
        if (__write_config(file, data[key], padding + 1)):
            file.write(tabs + "}")
        file.write(";\n")
    return True
