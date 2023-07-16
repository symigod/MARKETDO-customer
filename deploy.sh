while true; do
    echo "Please choose an option:"
    echo "1. PUSH TO GITHUB"
    echo "2. BUILD APK RELEASE + PUSH TO GITHUB"
    echo "0. EXIT"

    read -p "Enter your choice: " choice

    if [ "$choice" = "1" ]; then
        read -p "Enter commit message: " commit_message

        echo "=================================================="
        echo "Running git add . ..."
        echo "=================================================="
        git add .

        echo "=================================================="
        echo "Running git commit -m \"$commit_message\" ..."
        echo "=================================================="
        git commit -m "$commit_message"

        echo "=================================================="
        echo "Running git push -u origin main ..."
        echo "=================================================="
        git push -u origin main

    elif [ "$choice" = "2" ]; then
        echo "=================================================="
        echo "Running flutter build apk --release ..."
        echo "=================================================="
        flutter build apk --release

        read -p "Enter commit message: " commit_message

        echo "=================================================="
        echo "Running git add . ..."
        echo "=================================================="
        git add .

        echo "=================================================="
        echo "Running git commit -m \"$commit_message\" ..."
        echo "=================================================="
        git commit -m "$commit_message"

        echo "=================================================="
        echo "Running git push -u origin main ..."
        echo "=================================================="
        git push -u origin main

    elif [ "$choice" = "0" ]; then
        echo "Exiting..."
        exit 0

    else
        echo "Invalid choice."
    fi

    read -p "Press Enter to continue..."
done
