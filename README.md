# hello_me

A new Flutter application.

## Getting Started

### Question 1 :
SnappingSheetContent class, it allows the Snapping Sheet to be dragged or not , and customize it to lock overflow drag (to drag it out of max and min snapping position),
for example :
      SnappingSheet(
            lockOverflowDrag: true, // overflow drag is locked 
            sheetBelow: SnappingSheetContent(
                  // Pass in the scroll controller here!
              childScrollController: _myScrollController,
               draggable: true,
                  child: ListView(
                controller: _myScrollController,
                  reverse: false,
              ),
              ),
       )
### Question 2 : 
we can use positionFactor to specify a height .
for example :
snappingSheetController.snapToPosition(
      SnappingPosition.factor(positionFactor: 0.75),
    );
#### Question 3 :
GestureDetector provides more controls (like dragging) ,while InkWell has a limited number of gestures but it gives you ways to decorate the widget (like colors and border).
