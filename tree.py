import os
import shutil

base_path = "lib"

# Target structure mapping (file -> folder)
file_map = {
    "main.dart": "",

    "recipe.dart": "models",
    "shopping_item.dart": "models",

    "api_service.dart": "services",

    "recipe_provider.dart": "providers",
    "shopping_provider.dart": "providers",

    "recipe_feed_screen.dart": "screens",
    "recipe_detail_screen.dart": "screens",
    "shopping_list_screen.dart": "screens",

    "app_theme.dart": "utils",
    "pdf_service.dart": "utils",

    "recipe_card.dart": "widgets",
    "shimmer_card.dart": "widgets",
    "error_view.dart": "widgets",
    "empty_state.dart": "widgets",
}


def reorganize_files(base, mapping):
    for file_name, folder in mapping.items():
        src_path = os.path.join(base, file_name)

        # Skip if file doesn't exist
        if not os.path.exists(src_path):
            print(f"Skipping (not found): {file_name}")
            continue

        # Define destination folder
        dest_folder = os.path.join(base, folder) if folder else base
        os.makedirs(dest_folder, exist_ok=True)

        dest_path = os.path.join(dest_folder, file_name)

        # Move file
        shutil.move(src_path, dest_path)
        print(f"Moved: {file_name} → {folder or 'root'}")


reorganize_files(base_path, file_map)