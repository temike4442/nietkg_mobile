import 'package:flutter/material.dart';
import 'package:story_view/story_view.dart';

class StoryPageView extends StatefulWidget {
  const StoryPageView({Key? key, this.story}) : super(key: key);
  final story;
  @override
  _StoryPageViewState createState() => _StoryPageViewState();
}

class _StoryPageViewState extends State<StoryPageView> {
  final controller = StoryController();

  @override
  Widget build(BuildContext context) {
    List<StoryItem> storyItems = [];
    for (int i = 0; i < widget.story.length; i++) {
      if (widget.story[i].type == 'jpg') {
        storyItems.add(StoryItem.pageImage(
            url: widget.story[i].src.toString(),
            controller: controller,
            duration: Duration(seconds: 7)));
      }
      if (widget.story[i].type == 'mp4') {
        storyItems.add(StoryItem.pageVideo(widget.story[i].src.toString(),
            controller: controller, duration: Duration(seconds: 60)));
      }
      StoryItem.pageVideo('url', controller: controller);
    }

    return Material(
      child: StoryView(
        storyItems: storyItems,
        controller: controller,
        inline: false,
        repeat: false,
        onComplete: () {
          Navigator.pop(context);
        },
        onVerticalSwipeComplete: (direction) {
          if (direction == Direction.down) {
            Navigator.pop(context);
          }
        },
      ),
    );
  }
}
