# Sending trajetories to HANA
## JSON Format
Collected data should be formatted in JSON like in the following scheme: 
```json
{
    "trackPoints":
        [
            [47.667179, 9.168659, 1481625334952],
            [47.667180, 9.168669, 1481625334953]
        ]
}
```
As you can see, a trackpoint consists of latitude, longitude and a timestamp in milliseconds since the zero hour of Unix.

## Accessing the backend

You can find the backendscript under: 
* https://h04-d00.ucc.ovgu.de/gbi-student-042/importData/bringItToHana.xsjs
```diff
We will have another backend once we have finished the first development phase! 
```
If you want to to push your collected data to our backend, send a HTTP post request with the JSON object as body.

## Return codes:

The server response's body is a JSON object:
```json
{
    "code": 42,
    "message": "verbose description"
}
```

|  Code | Description  |
|---|---|
| 0 | No data in the body of your request  |
| 2  | SQL-Error(verbose description in the returned object) |
| 107  | JSON parse error  |
| 201  | Success |
