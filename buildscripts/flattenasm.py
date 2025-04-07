import sys
import os

def binToByteStr(file_path, skip_byte_count=0):
    input_file = open(file_path, 'rb')
    input_bytes = bytearray(input_file.read())
    output_string = ".bytes "
    byte_count = 0
    for byte in input_bytes:
        byte_count += 1
        if byte_count > skip_byte_count:
            byte_string = "0x%0.2X" % byte
            output_string += byte_string.replace("0x", "$").lower()
        if (byte_count - skip_byte_count) % 4 == 0:
            output_string += "\n.bytes "
        else:
            output_string += ","
    if skip_byte_count >= byte_count:
        return ""
    if output_string.endswith(","):
        output_string = output_string[:-1] + "\n"
    return output_string

def flattenIncludes(file_path, flatten_bin=False):
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
            elif line.startswith(".binary ") and flatten_bin:
                include_params = line.split()
                include_params_str = include_params[1]
                include_params_list = include_params_str.split(",")
                include_path_params = include_params_list[0]
                bytes_to_skip = 0
                try:
                    if len(include_params_list) > 1:
                        bytes_to_skip_params = include_params_list[1]
                        bytes_to_skip = int(bytes_to_skip_params)
                except ValueError as e:
                    bytes_to_skip = 0
                include_path = include_path_params.replace('"', '')
                include_output = binToByteStr(include_path, skip_byte_count=bytes_to_skip)
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
    except FileNotFoundError as e:
        print("Error:", e.filename, "not found! cwd:", os.getcwd(), file=sys.stderr)
        return ""

if __name__ == "__main__":
    if len(sys.argv) < 2:
        print("Please specify input file and optionally output file as first and second parameter, respectively.", file=sys.stderr)
        exit(0)
    output = flattenIncludes(sys.argv[1])
    if len(sys.argv) == 2:
        print(output)
        exit(0)
    if len(sys.argv) > 2:
        output_file = open(sys.argv[2], "w", newline='\n')
        print(output, file=output_file)
    