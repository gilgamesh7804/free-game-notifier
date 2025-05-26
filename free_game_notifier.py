import requests
import json
import firebase_admin
from firebase_admin import credentials, messaging
import os

# Load Firebase Admin credentials
cred = credentials.Certificate(r"C:\Users\chait\free_game_notifier\flutter_application_1\free-games-notifier-993f9-firebase-adminsdk-fbsvc-c358b67038.json")
firebase_admin.initialize_app(cred)

# Replace this with your actual FCM device token
DEVICE_TOKEN = "eBsmqpdzR02NXz5QW5jXlk:APA91bExuHLB00DICp5rxK_Ltu7LWAPbI-pit5G7e3nc5UIOv9zira8XRSr1jgwWxISfZYfB3sWMtDPccdqgqCKePrgBP4xj5qwugXU7ehqwweR39nNn35I"

# File to store the last game's title
LAST_GAME_FILE = "last_game.json"

def get_free_games():
    url = "https://store-site-backend-static.ak.epicgames.com/freeGamesPromotions?locale=en-US&country=US&allowCountries=US"
    response = requests.get(url)
    data = response.json()
    
    games = data["data"]["Catalog"]["searchStore"]["elements"]
    free_games = []
    for game in games:
        if game.get("promotions") and game["promotions"].get("promotionalOffers"):
            title = game["title"]
            image_url = game["keyImages"][0]["url"]
            free_games.append({"title": title, "image": image_url})
    return free_games

def get_last_game():
    if os.path.exists(LAST_GAME_FILE):
        with open(LAST_GAME_FILE, "r") as f:
            return json.load(f).get("title")
    return None

def save_last_game(title):
    with open(LAST_GAME_FILE, "w") as f:
        json.dump({"title": title}, f)

def send_push_notification(title, image_url):
    message = messaging.Message(
        notification=messaging.Notification(
            title="New Free Game!",
            body=title,
            image=image_url
        ),
        token=DEVICE_TOKEN,
    )
    response = messaging.send(message)
    print("✅ Notification sent:", response)

def main():
    free_games = get_free_games()
    if not free_games:
        print("No free games found.")
        return

    latest_game = free_games[0]
    last_title = get_last_game()

    if latest_game["title"] != last_title:
        print(f"New free game detected: {latest_game['title']}")
        send_push_notification(latest_game["title"], latest_game["image"])
        save_last_game(latest_game["title"])
    else:
        print("No new free game.")

if __name__ == "__main__":
    main()
