import os

base_path = "lib"

structure = {
    "models": ["recipe.dart"],
    "providers": ["recipe_provider.dart"],
    "screens": [
        "recipe_feed_screen.dart",
        "recipe_detail_screen.dart",
        "shopping_list_screen.dart",
    ],
    "widgets": [
        "recipe_card.dart",
        "loading_shimmer.dart",
    ],
    "": ["main.dart"],  # root file inside lib
}

def create_structure(base, structure):
    for folder, files in structure.items():
        folder_path = os.path.join(base, folder) if folder else base
        
        # Create folder
        os.makedirs(folder_path, exist_ok=True)
        
        # Create files
        for file in files:
            file_path = os.path.join(folder_path, file)
            
            if not os.path.exists(file_path):
                with open(file_path, "w") as f:
                    f.write(f"// {file}\n")
                print(f"Created: {file_path}")
            else:
                print(f"Already exists: {file_path}")

create_structure(base_path, structure)