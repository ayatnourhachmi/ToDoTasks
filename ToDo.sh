#!/bin/bash

# Function to create a new task
create_task() {
    echo "Let's create a new task!"
    echo "Enter the title of your task:"
    read title
    if [[ -z $title ]]; then
        echo "Oops! Looks like you forgot to enter a title. Please try again." >&2
        return 1
    fi

    echo "Add a short description (optional):"
    read description

    echo "Any specific location? (optional):"
    read location

    echo "When is it due? (format: YYYY-MM-DD):"
    read due_date
    if [[ -z $due_date ]]; then
        echo "Oops! You need to specify a due date. Please try again." >&2
        return 1
    fi

    echo "Any specific time? (optional, format: HH:MM):"
    read due_time

    # Check if the necessary fields are filled
    if [[ -z $title || -z $due_date ]]; then
        echo "Looks like some required fields are missing. Please try again." >&2
        return 1
    fi

    # Append task details to a CSV file
    echo "$title,$description,$location,$due_date,$due_time,false" >> tasks.csv

    echo "Great! Your task has been created and saved."
}

# Function to update an existing task
update_task() {
    echo "Let's update an existing task!"
    echo "Enter the title of the task you want to update:"
    read search_title

    # Search for the task by title in the CSV file
    if grep -q "^$search_title," tasks.csv; then
        # Prompt user for updated task details
        echo "Enter the new title (leave empty to keep current value):"
        read new_title

        echo "Update the description (leave empty to keep current value):"
        read new_description

        echo "Change the location (leave empty to keep current value):"
        read new_location

        echo "Modify the due date (format: YYYY-MM-DD, leave empty to keep current value):"
        read new_due_date

        echo "Update the due time (format: HH:MM, leave empty to keep current value):"
        read new_due_time

        # Update the task in the CSV file
        sed -i "/^$search_title,/c\\$new_title,$new_description,$new_location,$new_due_date,$new_due_time,false" tasks.csv

        echo "Task updated successfully."
    else
        echo "Oops! Task not found." >&2
    fi
}

# Function to delete an existing task
delete_task() {
    echo "Let's delete a task!"
    echo "Enter the title of the task you want to delete:"
    read search_title

    # Search for the task by title in the CSV file
    if grep -q "^$search_title," tasks.csv; then
        # Delete the task from the CSV file
        sed -i "/^$search_title,/d" tasks.csv

        echo "Task deleted successfully."
    else
        echo "Oops! Task not found." >&2
    fi
}

# Function to display all tasks
display_all_tasks() {
    echo "Here are all your tasks:"
    printf "%-20s %-30s %-20s %-15s %-10s %-10s\n" "Title" "Description" "Location" "Due Date" "Due Time" "Completed"
    echo "-------------------------------------------------------------------------------------------------------------"

    # Display each task from the CSV file with proper formatting
    while IFS=, read -r title description location due_date due_time completed; do
        printf "%-20s %-30s %-20s %-15s %-10s %-10s\n" "$title" "$description" "$location" "$due_date" "$due_time" "$completed"
    done < tasks.csv

    # Count the total number of tasks
    total_tasks=$(wc -l < tasks.csv)
    echo "Total tasks: $total_tasks"
}


# Function to display a specific task
display_task() {
    echo "Enter the title of the task you want to display:"
    read search_title

    # Search for the task by title in the CSV file
    if grep -q "^$search_title," tasks.csv; then
        # Display the task
        grep "^$search_title," tasks.csv
    else
        echo "Oops! Task not found." >&2
    fi
}

#List tasks of a given day in two output sections: completed and uncompleted
list_tasks_of_day() {
    echo "Enter the date of the tasks you want to list (format: YYYY-MM-DD):"
    read search_date

    # Search for the tasks by due date in the CSV file
    if grep -q ",$search_date," tasks.csv; then
        # Display the tasks
        echo "Here are the tasks due on $search_date:"
        echo "Completed tasks:"
        grep ",$search_date,true" tasks.csv
        echo "Uncompleted tasks:"
        grep ",$search_date,false" tasks.csv
    else
        echo "Oops! No tasks found for this date." >&2
    fi
}

# Main function
main() {
    while true; do
        echo "Welcome to your task manager!"

        display_all_tasks

        # Display choices to the user
        echo "What would you like to do today?"
        echo "1. Create a new task"
        echo "2. Update an existing task"
        echo "3. Delete a task"
        echo "4. Show all information about a task"
        echo "5. List tasks of a given day"
        echo "6. Exit"

        # Read user input
        read choice

        # Check user choice and call corresponding function
        case $choice in
            1)
                create_task
                ;;
            2)
                display_all_tasks
                update_task
                ;;
            3)
                display_all_tasks
                delete_task
                ;;
            4)
                display_all_tasks
                display_task
                ;;

            5)
                list_tasks_of_day
                ;;
            
            6)
                echo "Goodbye!"
                exit 0
                ;;
            *)
                echo "Hmm... I didn't quite get that. Please choose a number from 1 to 6." >&2
                ;;
        esac
    done
}

# Execute main function
main
