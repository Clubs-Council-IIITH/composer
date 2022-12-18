# composer

An intermediate service for Apollo Router that automatically healthchecks services and composes the supergraph schema using the available subgraphs.

## Configuration
All configuration options for the service reside in `config.yml`.

- `interval`: The interval (in seconds) at which the listed services are pinged to check if they are up.
- `timeout`: The time span (in seconds) after which a service is given up on and excluded from the supergraph.
- `services`: A list of (`name`, `url`) objects for each service to be included. 