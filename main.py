#!/usr/bin/env python3

import argparse
import math
from pytubefix import YouTube, Playlist
from pytubefix.contrib.search import Search, Filter

VERSION = '1.0'

def search(query: str):
  """
  Search for videos on YouTube based on the query provided
  """

  if not query:
    print('Please provide a search query')
    return
  
  filters = {
    'type': Filter.get_type("Video"),
  }

  # Searching for videos based on the query
  results = Search(query, filters=filters)

  # Displaying the search results
  for i, video in enumerate(results.videos):
    duration = f"{math.floor(video.length / 60)}:{str(video.length % 60).rjust(2, '0')}"
    print(f'{i + 1}. {video.title} ({duration}) - {video.watch_url}')

def download(url: str, *, settings: dict):
  """
  Download a video or playlist from YouTube based on the URL provided
  """

  if not url:
    print('Please provide a video URL')
    return
  
  videos = []

  # Checking if the URL is a playlist or a single video
  if 'playlist' in url:
    playlist = Playlist(url)
    videos = playlist.videos
  else:
    videos.append(YouTube(url))
  
  # Downloading the video(s)
  for video in videos:
    if settings['audio-only']:
      stream = video.streams.get_audio_only()
    else:
      stream = video.streams.get_highest_resolution()

    # Downloading the video to the specified output path
    if settings['output']:
      stream.download(output_path=settings['output'])
    else:
      stream.download()

def main():
  """
  Main function to parse command line arguments 
  """

  # Setting up the argument parser
  parser = argparse.ArgumentParser(prog='ytdl')
  subparsers = parser.add_subparsers()

  parser.add_argument('-v', '--version', action='version', version=f'%(prog)s {VERSION}')

  search_parser = subparsers.add_parser('search', aliases=['s'])
  search_parser.set_defaults(which='search')

  search_parser.add_argument('search', help='search query', type=str)

  download_parser = subparsers.add_parser('download', aliases=['dl'])
  download_parser.set_defaults(which='download', audio_only=False, output='')

  download_parser.add_argument('download', help='url of the video/playlist to download', type=str)
  download_parser.add_argument('-a', '--audio-only', type=bool)
  download_parser.add_argument('-o', '--output', type=str)

  args = parser.parse_args()

  # Handling the command line arguments
  if not vars(args):
    parser.print_help()
  elif args.which == 'search':
    search(args.search)
  elif args.which == 'download':
    settings = {
      'audio-only': args.audio_only,
      'output': args.output
    }

    download(args.download, settings=settings)

if __name__ == '__main__':
  main()