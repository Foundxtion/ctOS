def main():
    with open("src/foundation.txt", "r") as file:
        foundation = "".join(file.readlines())
    print(foundation)

if __name__ == "__main__":
    main()
