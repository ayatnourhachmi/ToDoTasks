Todo

This script serves as a simple task manager, allowing users to create, update, delete, complete, display, and search tasks.
Data Storage

Tasks are stored in a CSV file named tasks.csv. Each task is represented as a row in the CSV file with the following columns:

    ID: Unique identifier for the task
    Title: Title of the task
    Description: Description of the task (optional)
    Location: Specific location for the task (optional)
    Due Date: Deadline for the task (format: YYYY-MM-DD)
    Due Time: Specific time for the task (optional, format: HH:MM)
    State: Current state of the task (incomplete or complete)

Code Organization

The script is organized into functions, each responsible for a specific task:

    Main Script Logic: Handles user input and invokes appropriate functions based on the provided command.
    Task Management Functions: Functions like create_task, update_task, delete_task, complete_task, display_task, list_tasks_of_day, search_task, and display_all_tasks are responsible for managing tasks.
    Validation Functions: validate_date and validate_time validate date and time formats, respectively.
    Helper Functions: check_tasks_for_date is used to filter tasks for a specific date.


To run the program, execute the script todo.sh with one of the following commands:

    ./todo.sh create: Create a new task.
    ./todo.sh update [task_id]: Update an existing task with the specified ID.
    ./todo.sh delete [task_id]: Delete a task with the specified ID.
    ./todo.sh complete [task_id]: Mark a task with the specified ID as complete.
    ./todo.sh show [task_id]: Display information about the task with the specified ID.
    ./todo.sh list [date]: List tasks for a specific day (format: YYYY-MM-DD).
    ./todo.sh search [title]: Search for tasks by title.
    ./todo.sh display-all: Display all tasks.
    ./todo.sh man: Display the manual with usage instructions and available commands.

If no command is provided, the script will display tasks for the current day by default.
