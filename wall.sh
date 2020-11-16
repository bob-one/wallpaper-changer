#!/bin/bash
shopt -s nullglob
# Now grab a manly/womanly beer, or a glass of delicious whisk(e)y (from isle of islay),
# set up crontab, startup-script, alias or a hot-key and move on to something more productive TODO: Grab a beer

# I use it in Qtile since their wallpaper widget kind of sucks. Mayby I'll make a new widget in python and submit it to them
# Oh, and if you find this script useful, please use it, abuse it, misuse it and preferably make it better
# Best wishes and get well soon, sincerely yours -andre

set_wallpaper () {
    # Setting the wallpaper usin feh
    # TODO this specific awk command is dangerous, and can easily be exploited, need to change it.
    WALLPAPER=$( awk '{if(NR=="'"$RAND"'") print$0}' $SCRIPT_DATA/list_of_wallpapers)
    feh --bg-scale $WALLPAPER 2>>$SCRIPT_DATA/wallpaper_error
    #echo $WALLPAPER > $SCRIPT_PATH/wallpaper # If you need to display the name/path of the current wallpaper some place (like the status bar)
    exit
}

start_over () {
    # reset INDX and RAND
    INDX=1; RAND=1
    echo $INDX > $SCRIPT_DATA/current_wallpaper_index
    
    # Get the number of jpg or png in the given wallpaper folder
    NUMJPGS=($WALLPAPER_PATH/*.jpg)
    NUMJPGS=${#NUMJPGS[@]}
    NUMPNGS=($WALLPAPER_PATH/*.png)
    NUMPNGS=${#NUMPNGS[@]}
    NUMPICS=$(($NUMJPGS + $NUMPNGS +1))
    echo $NUMPICS > $SCRIPT_DATA/number_of_pics # For use in the main loop
    
    # Generate the random numbers equal to the number of pictures in the wallpaper folder, without repeating any numbers
    # Also uses source to make sure it completes this task before moving on
    source $SCRIPT_PATH/generate_non_repeating_random_numbers.sh $NUMPICS $NUMPICS

    # Create a list of all the filenames with path and save to a file
    echo "" > $SCRIPT_DATA/list_of_wallpapers
    for f in "$WALLPAPER_PATH"/*
    do
        echo "$f" >> $SCRIPT_DATA/list_of_wallpapers
    done

    set_wallpaper $RAND 
}

cycle_through () {
    # Increment through the list of indexes to set the wallpapers each time the script is run
    INDX=$(( INDX+1 ))
    echo $INDX > $SCRIPT_DATA/current_wallpaper_index
    RAND=$( head -n 1 $SCRIPT_DATA/list_of_non_repeating_random_numbers )
    sed -i -e "1d" $SCRIPT_DATA/list_of_non_repeating_random_numbers
    set_wallpaper $RAND 
}

# Standard check in allmost all of my scripts, if sudo for some reason is needed, then remove this check
[[ $UID == 0 ]] && ( echo "Dont run an unknown script as sudo, atleast read through it, and try to understand it before you try sudo on it"; exit )

# Get the path to where this script is run from and asigning it the the variable $SCRIPT_PATH
# In case it's a symlink: Resolve $SOURCE until the it's no longer a symlink
# If $SOURCE was a relative symlink, resolve it relative to the path where the symlink was located
SOURCE="${BASH_SOURCE[0]}"
while [ -h "$SOURCE" ]; do
    SCRIPT_PATH="$( cd -P "$( dirname "$SOURCE" )" >/dev/null 2>&1 && pwd )"
    SOURCE="$(readlink "$SOURCE")"
    [[ $SOURCE != /* ]] && SOURCE="$SCRIPT_PATH/$SOURCE"
done
SCRIPT_PATH="$( cd -P "$( dirname "$SOURCE" )" >/dev/null 2>&1 && pwd )"
SCRIPT_DATA="$SCRIPT_PATH/data"
# Create neccesary files, for storing values for later use, if they don't exists
[[ ! -d "$SCRIPT_DATA" ]] && ( mkdir $SCRIPT_PATH/data )
[[ ! -f "$SCRIPT_DATA/current_wallpaper_index" ]] && ( touch $SCRIPT_DATA/current_wallpaper_index; echo "reset" > $SCRIPT_DATA/current_wallpaper_index )
[[ ! -f "$SCRIPT_DATA/list_of_non_repeating_random_numbers" ]] && ( touch $SCRIPT_DATA/list_of_non_repeating_random_numbers )
[[ ! -f "$SCRIPT_DATA/list_of_wallpapers" ]] && ( touch $SCRIPT_DATA/list_of_wallpapers )
[[ ! -f "$SCRIPT_DATA/number_of_pics" ]] && ( touch $SCRIPT_DATA/number_of_pics )
[[ ! -f "$SCRIPT_DATA/wallpaper_error" ]] && ( touch $SCRIPT_DATA/wallpaper_error )

# Cheking if the path to the wallpaperfolder is given if you intend to use it for differently themed wallpaper folders
[[ "$1" = "" ]] && ( echo -e " Please add location to your wallpaper folder."; exit )
[[ ! "$1" = "" ]] && WALLPAPER_PATH="$1"

# You can also just hard code the path if you dont intend to use it for differently themed wallpaper folders
#WALLPAPER_PATH="$HOME/Pictures/wallp"

# Set PATH variable to be able to use crontab to set the wallpaper
export DISPLAY=:0
export XAUTHORITY=$HOME/.Xauthority
export XDG_RUNTIME_DIR=/run/user/1000

read INDX < $SCRIPT_DATA/current_wallpaper_index 2>>$SCRIPT_DATA/wallpaper_error
[[ "$INDX" = "reset" ]] && ( start_over )
read LIMIT < $SCRIPT_DATA/number_of_pics 2>>$SCRIPT_DATA/wallpaper_error
[[ $INDX -eq $LIMIT ]] && ( start_over )
[[ $INDX -lt $LIMIT ]] && ( cycle_through )
