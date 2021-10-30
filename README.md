# Exporter for Redmine

Export Redmine issues to Google Sheets

## Requirements

-   Docker

## Development

1.  Run command to start a container.

    ```sh
    docker-compose build
    docker-compose run --rm --entrypoint /bin/bash app
    ```

2.  Edit docker-entrypoint.thor.

3.  Run command to stop the container.

    ```sh
    docker-compose down
    ```

## Author

naoigcat

## License

MIT
