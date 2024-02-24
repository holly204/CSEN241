import json
import datetime
import requests

def handle(req):
    user_input = req.lower()  # Get user input lower case

    # Case 1: User asks for the name
    if 'name' in user_input:
        return [
                "My name is Li",
                "They call me Li",
                "I'm known as Li"
            ]

    # Case 2: User asks for the current date and/or time
    elif 'time' in user_input or 'date' in user_input:
        now = datetime.datetime.now()
        date_str = now.strftime('%Y-%m-%d')
        time_str = now.strftime('%H:%M:%S')
        return [
            "The current date and time is {} {}.".format(date_str, time_str),
            "Right now, it's {} {}.".format(date_str, time_str),
            "As of this moment, it's {} {}.".format(date_str, time_str)
        ]

    # Case 3: User asks to generate a figlet
    elif 'figlet' in user_input:
        payload = req.split('figlet', 1)[1].strip()  # get the word after figlet and remove space
        gateway = "http://10.62.0.4:8080/function/figlet"
        response = requests.post(gateway, data=payload)
        return response.text

    # Default case if none of the above match
    else:
        return ["I'm not sure how to answer it. Can you try asking something else?"]
