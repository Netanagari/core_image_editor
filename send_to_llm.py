import os

def collect_text_files(directory, extensions, output_file):
    with open(output_file, 'w', encoding='utf-8') as out_file:
        for root, _, files in os.walk(directory):
            for file in files:
                if file.endswith(tuple(extensions)):
                    file_path = os.path.join(root, file)
                    try:
                        with open(file_path, 'r', encoding='utf-8') as f:
                            out_file.write(f"\n--- File: {file_path} ---\n\n")
                            out_file.write(f.read() + "\n\n")
                    except Exception as e:
                        print(f"Error reading {file_path}: {e}")

if __name__ == "__main__":
    directory = input("Enter the directory to scan: ")
    extensions = input("Enter file extensions to include (comma-separated, e.g., .txt,.md,.py): ").split(',')
    output_file = "merged_text_output.txt"
    
    collect_text_files(directory, extensions, output_file)
    print(f"All text content has been saved to {output_file}")
