import os
from telethon import TelegramClient, events, Button
from messages import Messages
from download_handler import handle_url
from config import API_ID, API_HASH, BOT_TOKEN
import logging

logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

client = TelegramClient('bot', API_ID, API_HASH).start(bot_token=BOT_TOKEN)

@client.on(events.NewMessage(pattern='/start'))
async def start(event):
    user = await event.get_sender()
    buttons = [
        [Button.url("לערוץ עדכונים", "https://t.me/bot_sratim_sdarot")],
        [Button.inline("אודות", "about"), Button.inline("עזרה", "help")]
    ]
    await event.respond(
        f"היי [{user.first_name}](tg://user?id={user.id}) 👋\n"
        "אני בוט שמעלה מיוטיוב ומאתרים.\n\n"
        "שלח לי קישור ואני אמשיך משם...",
        buttons=buttons
    )

@client.on(events.CallbackQuery)
async def callback(event):
    data = event.data.decode()
    if data == "about":
        await event.respond(Messages.ABOUT_TEXT)
    elif data == "help":
        await event.respond(Messages.HELP_TEXT)
    await event.answer()

@client.on(events.NewMessage(func=lambda e: e.photo))
async def handle_thumb(event):
    user_id = event.sender_id
    try:
        os.makedirs('thumbs', exist_ok=True)
        path = f'thumbs/{user_id}.jpg'
        await event.download_media(file=path)
        await event.respond("התמונה הממוזערת נשמרה בהצלחה!")
    except Exception as e:
        logger.error(f"Error saving thumbnail: {e}")
        await event.respond("שגיאה בשמירת התמונה הממוזערת")

@client.on(events.NewMessage(pattern='/del_thumb'))
async def del_thumb(event):
    user_id = event.sender_id
    path = f'thumbs/{user_id}.jpg'
    if os.path.exists(path):
        try:
            os.remove(path)
            await event.respond("התמונה הממוזערת נמחקה בהצלחה!")
        except Exception as e:
            logger.error(f"Error deleting thumbnail: {e}")
            await event.respond("שגיאה במחיקת התמונה הממוזערת")
    else:
        await event.respond("לא נמצאה תמונה ממוזערת!")

@client.on(events.NewMessage(pattern='/view_thumb'))
async def view_thumb(event):
    user_id = event.sender_id
    path = f'thumbs/{user_id}.jpg'
    if os.path.exists(path):
        try:
            await event.respond(file=path)
        except Exception as e:
            logger.error(f"Error sending thumbnail: {e}")
            await event.respond("שגיאה בשליחת התמונה הממוזערת")
    else:
        await event.respond("לא נמצאה תמונה ממוזערת!")

@client.on(events.NewMessage(func=lambda e: e.text and e.text.startswith('http')))
async def url_handler(event):
    await handle_url(event, client)

def main():
    client.run_until_disconnected()

if __name__ == '__main__':
    main()
