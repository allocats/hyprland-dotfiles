#!/bin/bash

WALLPAPER_DIR="$HOME/.wallpapers"
THUMBNAIL_DIR="$HOME/.cache/wallpaper-thumbs"
THUMBNAIL_SIZE="300x250"

mkdir -p "$THUMBNAIL_DIR"

generate_thumbnail() {
    local wallpaper="$1"
    local filename=$(basename "$wallpaper")
    local thumbnail="$THUMBNAIL_DIR/${filename%.*}.png"
    
    if [[ ! -f "$thumbnail" ]] || [[ "$wallpaper" -nt "$thumbnail" ]]; then
        echo "Generating thumbnail for $filename..." >&2
        convert "$wallpaper" -resize "$THUMBNAIL_SIZE^" -gravity center -extent "$THUMBNAIL_SIZE" "$thumbnail" 2>/dev/null
    fi
    
    echo "$thumbnail"
}

build_entries() {
    find "$WALLPAPER_DIR" -type f \( -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.png" -o -iname "*.webp" \) | sort | while read -r wallpaper; do
        if [[ -f "$wallpaper" ]]; then
            filename=$(basename "$wallpaper" | sed 's/\.[^.]*$//')  
            thumbnail=$(generate_thumbnail "$wallpaper")
            
            printf "%s\x00icon\x1f%s\x1finfo\x1f%s\n" "$filename" "$thumbnail" "$wallpaper"
        fi
    done
}

if [[ ! -d "$WALLPAPER_DIR" ]]; then
    echo "Error: Wallpaper directory '$WALLPAPER_DIR' not found!"
    echo "Please create it and add some wallpapers."
    exit 1
fi

selected=$(build_entries | rofi \
    -dmenu \
    -i \
    -p "󰸉 Wallpapers " \
    -theme "$HOME/.config/rofi/configs/wallpapers.rasi" \
    -show-icons \
    -eh 2)

if [[ -n "$selected" ]]; then
    echo "Selected: '$selected'" >&2

    wallpaper_path=$(find "$WALLPAPER_DIR" -type f -name "${selected}.*" | head -1)
    if [[ -z "$wallpaper_path" ]]; then
        wallpaper_path=$(find "$WALLPAPER_DIR" -type f -name "*${selected}*" | head -1)
    fi
    
    echo "Found wallpaper path: '$wallpaper_path'" >&2
    
    if [[ -f "$wallpaper_path" ]]; then
        echo "Setting wallpaper: $(basename "$wallpaper_path")"
        
        FPS=60
        TYPE="any"
        DURATION=2
        BEZIER=".43,1.19,1,.4"
        SWWW_PARAMS="--transition-fps $FPS --transition-type $TYPE --transition-duration $DURATION --transition-bezier $BEZIER"
        
        swww img "$wallpaper_path" $SWWW_PARAMS
        
        wallust run "$wallpaper_path"
        swaync-client -rs
        
        ln -sf "$wallpaper_path" ~/.config/rofi/.current_wallpaper
        ln -sf "$wallpaper_path" ~/.config/hypr/.current_wallpaper
        echo "$wallpaper_path" > "$HOME/.current_wallpaper"
    fi
fi
