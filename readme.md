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
As you can see, a trackpoint consists of latitude, longitude and a timestamp in milliseconds since the zero hour of computer science.

## Accessing the backend

You can find the backendscript under: 
* https://h04-d00.ucc.ovgu.de/gbi-student-042/bringItToHana.xsjs
<font color='red'>We will have another backend once we have finished the first development phase! </font>
<font color='red'>At the moment, you have to authenticate. This will be removed later on</font>

If you want to to push your collected data to our backend via REST, append **?dataObj=** and then the stringified JSON-Object.

## Return codes:

|  Code | Description  |
|---|---|
| 42 | Marc is the best  |
|   |   |
|   |   |
|   |   |
