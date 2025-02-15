import 'package:flutter/material.dart';
import 'package:taurusai/models/job.dart';

class SwipeableJobCard extends StatefulWidget {
  final Job job;
  final VoidCallback onSwipeLeft;
  final VoidCallback onSwipeRight;
  final VoidCallback onSwipeUp;
  final VoidCallback onTap;

  SwipeableJobCard({
    required this.job,
    required this.onSwipeLeft,
    required this.onSwipeRight,
    required this.onSwipeUp,
    required this.onTap,
  });

  @override
  _SwipeableJobCardState createState() => _SwipeableJobCardState();
}

class _SwipeableJobCardState extends State<SwipeableJobCard> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onPanUpdate: (details) {
        if (details.delta.dx > 20) {
          widget.onSwipeRight();
        } else if (details.delta.dx < -20) {
          widget.onSwipeLeft();
        } else if (details.delta.dy < -20) {
          widget.onSwipeUp();
        }
      },
      onTap: widget.onTap,
      child: Card(
        elevation: 4,
        margin: EdgeInsets.all(16),
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    backgroundImage: NetworkImage(widget.job.companyLogo),
                    radius: 30,
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.job.title,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                          ),
                        ),
                        Text(
                          widget.job.company,
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16),
              Text(
                widget.job.location ?? '',
                style: TextStyle(fontSize: 16),
              ),
              SizedBox(height: 16),
              Text(
                widget.job.description,
                style: TextStyle(fontSize: 16),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
              SizedBox(height: 16),
              Text(
                'Posted: ${widget.job.postedDate}',
                style: TextStyle(color: Colors.grey[600]),
              ),
              SizedBox(height: 16),
              ElevatedButton(
                onPressed: widget.onTap,
                child: Text('View Details'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.lightBlue[300],
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
