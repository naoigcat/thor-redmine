# Exporter for Redmine

Export Redmine issues to Google Sheets

## Requirements

-   Docker

## Usage

### Preparation

-   Enter the Redmine API endpoint in API_ENDPOINT in .env
-   Issue Redmine API access key, and enter it in API_KEY in .env
-   Create a spreadsheet in Google Drive and add the 'issues' sheet, and enter the id of it in SHEETS_KEY in .env
-   Create a project on Google Cloud Platform and make a service account key, and put it in the root directory as .key.json
-   Grant the spreadsheet editing permission to the created service account

### Export

Run below command.

```sh
docker-compose build
docker-compose run --rm app export
docker-compose down
```

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
