import sys
import os

def flattenIncludes(file_path):
    output_string = ""
    input_file = None
    try:
        input_file = open(file_path)
        for line in input_file.readlines():
            if line.startswith(".include "):
                include_path = line.split()[1].replace('"', '')
                include_output = flattenIncludes(include_path)
                if include_output == "":
                    output_string += line
                else:
                    output_string += include_output
            else:
                output_string += line
        input_file.close()
        if not output_string.endswith("\n"):
            output_string += '\n'
        return output_string
    except FileNotFoundError:
        print("Error:", file_path, "not found!", file=sys.stderr)
        return ""

if __name__ == "__main__":
    if len(sys.argv) < 2:
        print("Please specifiy input file and optionally output file as first and second parameter, respectively.", file=sys.stderr)
        exit(0)
    output = flattenIncludes(sys.argv[1])
    if len(sys.argv) == 2:
        print(output)
        exit(0)
    if len(sys.argv) > 2:
        output_file = open(sys.argv[2], "w", newline='\n')
        print(output, file=output_file)
    