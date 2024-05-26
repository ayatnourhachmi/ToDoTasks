#!/bin/bash

if [[ ! -f tasks.csv ]]; then
    touch tasks.csv
    echo "ID,Title,Description,Location,Due Date,Due Time,State" > tasks.csv
fi

validate_date() {
    date_format="^[0-9]{4}-[0-9]{2}-[0-9]{2}$"
    if [[ $1 =~ $date_format ]]; then
        return 0
    else
        return 1
    fi
}

validate_time() {
    if ! [[ "$1" =~ ^([01]?[0-9]|2[0-3]):[0-5][0-9]$ ]]; then
        echo "Invalid time format. Please use HH:MM." >&2
        return 1
    fi
    return 0
}

create_task() {
    echo "Let's create a new task!"
    echo "Enter the title of your task:"
    read -r title
    if [[ -z $title ]]; then
        echo "Oops! Looks like you forgot to enter a title. Please try again." >&2
        return 1
    fi

    echo "Add a short description (optional):"
    read -r description

    echo "Any specific location? (optional):"
    read -r location

    echo "When is it due? (format: YYYY-MM-DD):"
    read -r due_date
    if [[ -z $due_date ]]; then
        echo "Oops! You need to specify a due date. Please try again." >&2
        return 1
    elif ! validate_date "$due_date"; then
        echo "Invalid due date. Please try again." >&2
        return 1
    fi

    echo "Any specific time? (optional, format: HH:MM):"
    read -r due_time
    if [[ -n $due_time ]] && ! validate_time "$due_time"; then
        echo "Oops! You need to specify a valid time. Please try again." >&2
        return 1
    fi

    task_id=$(awk -F, 'NR > 1 { if ($1 > max) max = $1 } END { print max + 1 }' tasks.csv)
    task_id=${task_id:-1}

    echo "$task_id,$title,$description,$location,$due_date,$due_time,incomplete" >> tasks.csv

    echo "Great! Your task has been created and saved with ID $task_id."
}

update_task() {
    if [[ -z $1 ]]; then
        echo "You need to provide the task ID to update." >&2
        return 1
    fi

    task_id=$1
    old_task=$(grep "^$task_id," tasks.csv)
    if [[ -z $old_task ]]; then
        echo "Oops! Task not found." >&2
        return 1
    fi

    IFS=, read -r old_id old_title old_description old_location old_due_date old_due_time old_state <<< "$old_task"

    echo "Enter the new title (leave empty to keep current value: $old_title):"
    read -r new_title
    new_title=${new_title:-$old_title}

    echo "Update the description (leave empty to keep current value: $old_description):"
    read -r new_description
    new_description=${new_description:-$old_description}

    echo "Change the location (leave empty to keep current value: $old_location):"
    read -r new_location
    new_location=${new_location:-$old_location}

    echo "Modify the due date (format: YYYY-MM-DD, leave empty to keep current value: $old_due_date):"
    read -r new_due_date
    if [[ -n $new_due_date ]] && ! validate_date "$new_due_date"; then
        echo "Invalid due date. Please try again." >&2
        return 1
    fi
    new_due_date=${new_due_date:-$old_due_date}

    echo "Update the due time (format: HH:MM, leave empty to keep current value: $old_due_time):"
    read -r new_due_time
    if [[ -n $new_due_time ]] && ! validate_time "$new_due_time"; then
        echo "Invalid due time. Please try again." >&2
        return 1
    fi
    new_due_time=${new_due_time:-$old_due_time}

    sed -i "/^$task_id,/c\\$task_id,$new_title,$new_description,$new_location,$new_due_date,$new_due_time,$old_state" tasks.csv

    echo "Task updated successfully."
}

delete_task() {
    if [[ -z $1 ]]; then
        echo "You need to provide the task ID to delete." >&2
        return 1
    fi

    task_id=$1
    if grep -q "^$task_id," tasks.csv; then
        sed -i "/^$task_id,/d" tasks.csv
        echo "Task deleted successfully."
    else
        echo "Oops! Task not found." >&2
    fi
}

complete_task() {
    if [[ -z $1 ]]; then
        echo "You need to provide the task ID to complete." >&2
        return 1
    fi

    task_id=$1
    task=$(grep "^$task_id," tasks.csv)
    if [[ -z $task ]]; then
        echo "Oops! Task not found." >&2
        return 1
    fi

    sed -i "/^$task_id,/s/incomplete/complete/" tasks.csv

    echo "Task marked as complete."
}

display_task() {
    if [[ -z $1 ]]; then
        echo "You need to provide the task ID to display." >&2
        return 1
    fi

    task_id=$1
    task=$(grep "^$task_id," tasks.csv)
    if [[ -z $task ]]; then
        echo "Oops! Task not found." >&2
        return 1
    fi

    IFS=, read -r id title description location due_date due_time state <<< "$task"
    echo "Task ID: $id"
    echo "Title: $title"
    echo "Description: $description"
    echo "Location: $location"
    echo "Due Date: $due_date"
    echo "Due Time: $due_time"
    echo "State: $state"
}

search_task() {
    if [[ -z $1 ]]; then
        echo "You need to provide the title to search." >&2
        return 1
    fi

    local title=$1
    echo "Searching for tasks with title containing '$title':"
    echo ""

    awk -F, -v title="$title" 'BEGIN {IGNORECASE=1; found=0} 
    NR > 1 && $2 ~ title {
        printf "%-5s %-20s %-25s %-10s %-12s %-10s %-10s\n", "ID", "Title", "Description", "Location", "Due Date", "Due Time", "State"
        printf "%-5s %-20s %-25s %-10s %-12s %-10s %-10s\n", $1, $2, $3, $4, $5, ($6 == "" ? "" : $6), $7
        found=1
    } 
    END {
        if (found == 0) {
            print "\nNo tasks found with this title."
        }
    }' tasks.csv
}

display_all_tasks() {
    echo "Here are all your tasks:"
    printf "%-5s %-20s %-25s %-10s %-12s %-10s %-10s\n" "ID" "Title" "Description" "Location" "Due Date" "Due Time" "State"
    tail -n +2 tasks.csv | while IFS=, read -r id title description location due_date due_time state; do
        printf "%-5s %-20s %-25s %-10s %-12s %-10s %-10s\n" "$id" "$title" "$description" "$location" "$due_date" "$due_time" "$state"
    done
}

check_tasks_for_date() {
    local target_date=$1

    local completed_tasks=()
    local uncompleted_tasks=()

    while IFS=, read -r id task_name category location date time state; do
        if [[ "$date" == "$target_date" ]]; then
            if [[ "$state" == "complete" ]]; then
                completed_tasks+=("$id,$task_name,$category,$location,$date,$time,$state")
            elif [[ "$state" == "incomplete" ]]; then
                uncompleted_tasks+=("$id,$task_name,$category,$location,$date,$time,$state")
            fi
        fi
    done < <(tail -n +2 tasks.csv)

    print_tasks() {
        local task_array=("$@")
        if [[ ${#task_array[@]} -eq 0 ]]; then
            echo "None"
        else
            printf "%-5s %-20s %-25s %-10s %-12s %-10s %-10s\n" "ID" "Title" "Description" "Location" "Due Date" "Due Time" "State"
            for task in "${task_array[@]}"; do
                IFS=, read -r id task_name category location date time state <<< "$task"
                printf "%-5s %-20s %-25s %-10s %-12s %-10s %-10s\n" "$id" "$task_name" "$category" "$location" "$date" "$time" "$state"
            done
        fi
    }

    echo "Here are the tasks for $target_date:"
    echo "Completed tasks:"
    echo ""
    print_tasks "${completed_tasks[@]}"
    echo ""
    echo ""
    echo "Uncompleted tasks:"
    echo ""
    print_tasks "${uncompleted_tasks[@]}"
}

list_tasks_of_day() {
    if [[ -z $1 ]]; then
        echo "You need to provide the date (YYYY-MM-DD) to list tasks." >&2
        return 1
    fi

    local date=$1
    if ! validate_date "$date"; then
        echo "Invalid date format. Please use YYYY-MM-DD." >&2
        return 1
    fi

    check_tasks_for_date "$date"
}

display_today_tasks() {
    local today=$(date +%Y-%m-%d)
    check_tasks_for_date "$today"
}

# Main
if [[ -z $1 ]]; then
    display_today_tasks
else
    case "$1" in
        man)
            echo "Usage: ./todo.sh [create|update|delete|complete|show|list|search|display-all]"
            echo ""
            echo "Commands:"
            echo "  create: Create a new task"
            echo "  update: Update an existing task"
            echo "  delete: Delete a task"
            echo "  complete: Mark a task as complete"
            echo "  show: Display information about a task"
            echo "  list: List tasks of a specific day"
            echo "  search: Search for tasks by title"
            echo "  display-all: Display all tasks"
            echo ""
            echo "If no command is provided, the script will display tasks for the current day."
            ;;

        create)
            create_task
            ;;
        update)
            update_task "$2"
            ;;
        delete)
            delete_task "$2"
            ;;
        complete)
            complete_task "$2"
            ;;
        show)
            display_task "$2"
            ;;
        list)
            list_tasks_of_day "$2"
            ;;
        search)
            search_task "$2"
            ;;
        display-all)
            display_all_tasks 
            ;;
        *)
            echo "Unrecognized argument: $1"
            echo "Please refer to the manual for more help: ./todo.sh man"
            ;;
    esac
fi
