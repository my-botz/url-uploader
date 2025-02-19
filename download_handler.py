import os
import yt_dlp
from telethon import Button
import asyncio
import logging

logger = logging.getLogger(__name__)

async def handle_url(event, client):
    url = event.text
    try:
        with yt_dlp.YoutubeDL({'quiet': True}) as ydl:
            info = ydl.extract_info(url, download=False)
            title = info.get('title', 'Video')
            
        buttons = [
            [
                Button.inline("השאר שם מקורי", f"download_original_{url}"),
                Button.inline("שנה שם", f"rename_{url}")
            ]
        ]
        
        await event.respond(
            f"נמצא: {title}\nהאם תרצה לשנות את השם?",
            buttons=buttons
        )
        
    except Exception as e:
        logger.error(f"Error processing URL: {e}")
        await event.respond(f"שגיאה בעיבוד הקישור: {str(e)}")

async def download_and_upload(event, url, filename, as_video=True):
    status_msg = await event.respond("מתחיל בהורדה...")
    
    try:
        # Download options
        ydl_opts = {
            'outtmpl': filename,
            'quiet': True
        }
        
        # Download the file
        with yt_dlp.YoutubeDL(ydl_opts) as ydl:
            ydl.download([url])
        
        await status_msg.edit("הורדה הושלמה, מעלה לטלגרם...")
        
        # Check for custom thumbnail
        user_id = event.sender_id
        thumb_path = f'thumbs/{user_id}.jpg'
        thumb = thumb_path if os.path.exists(thumb_path) else 'default_thumb.jpg'
        
        # Upload to Telegram
        if as_video:
            await event.client.send_file(
                event.chat_id,
                filename,
                thumb=thumb,
                supports_streaming=True
            )
        else:
            await event.client.send_file(
                event.chat_id,
                filename,
                thumb=thumb
            )
        
        await status_msg.delete()
        os.remove(filename)  # Clean up
        
    except Exception as e:
        logger.error(f"Error in download/upload: {e}")
        await status_msg.edit(f"שגיאה: {str(e)}")
