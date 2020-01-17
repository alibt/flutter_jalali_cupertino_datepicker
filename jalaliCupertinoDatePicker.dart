import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:shamsi_date/shamsi_date.dart';
import 'package:whisper/ui/shared/staticStrings.dart';
import 'package:whisper/ui/shared/stringHelpers.dart';
import 'package:whisper/ui/shared/textStyles.dart';

///this widget is a datePicker, built using cupertino picker
///[initialDate] is [minimumdate]
///default [minimumDate] is 1 second from Epoch
///default [maximumDate] is now
///this widget uses [shamsi_date] library to convert [DateTime] to [Jalali]
//Todo JalaliDatePicker 1. add correction of leap year and number of days for each month
//Todo JalaliDatePicker 2. rebuild on month changes if necessary to change number of days
//Todo check if build method on showmodal also gets run as manytime as this widget
const double _kItemExtent = 32.0;
const double offAxisFraction = 0.45;
// const bool _kUseMagnifier = false;
// const double _kMagnification = 1.08;
// const double _kDatePickerPadSize = 12.0;
// const double _kSqueeze = 1.25;
const Color _kBackgroundColor = Colors.transparent;
const EdgeInsets rightPadding = EdgeInsets.only(right: 10.0);
const double pickerWidth = 340;
enum JalaliCupertionCalendarMode { yearMonth, yearMonthDay }

// const TextStyle _kDefaultPickerTextStyle = TextStyle(
//   letterSpacing: -0.83,
// );

class JalaliCupertinoDatePicker extends StatefulWidget {
  final JalaliCupertionCalendarMode mode;
  final ValueChanged<Jalali> onDateChanged;
  final Jalali minimumDate;
  final Jalali maximumDate;

  JalaliCupertinoDatePicker(
      {@required JalaliCupertionCalendarMode mode,
      @required ValueChanged<Jalali> onDateChanged,
      Jalali minimumDate,
      Jalali maximumDate})
      : this.mode = mode ?? JalaliCupertionCalendarMode.yearMonthDay,
        this.minimumDate = minimumDate ??
            Jalali.fromDateTime(DateTime.fromMillisecondsSinceEpoch(1000)),
        this.maximumDate = maximumDate ?? Jalali.fromDateTime(DateTime.now()),
        this.onDateChanged = onDateChanged,
        assert((minimumDate <= maximumDate),
            'maximumdate must be later than minimumdate');

  @override
  _JalaliCupertinoDatePickerState createState() =>
      _JalaliCupertinoDatePickerState();
}

class _JalaliCupertinoDatePickerState extends State<JalaliCupertinoDatePicker> {
  List<Widget> pickers;
  int numberOfColumns;
  FixedExtentScrollController _dayController;
  FixedExtentScrollController _monthController;
  int selectedYear;
  int selectedMonth;
  int selectedDay;

  @override
  void initState() {
    selectedDay = widget.minimumDate.day;
    selectedMonth = widget.minimumDate.month;
    selectedYear = widget.minimumDate.year;
    _dayController = FixedExtentScrollController(initialItem: selectedDay - 1);
    _monthController =
        FixedExtentScrollController(initialItem: selectedMonth - 1);
    if (widget.mode == JalaliCupertionCalendarMode.yearMonth) {
      numberOfColumns = 2;
    } else
      numberOfColumns = 3;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    print("JalaliCupertinoDatePicker Build method !!");
    if (numberOfColumns == 3) {
      return Directionality(
        textDirection: TextDirection.rtl,
        child: NotificationListener<ScrollEndNotification>(
          onNotification: _readSelectedAndCallBackIfDateIsValid,
          child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.max,
              children: <Widget>[
                _daysColumnBuilder(),
                _monthColumnBuilder(),
                _yearColumnBuilder()
              ]),
        ),
      );
    } else {
      return Directionality(
        textDirection: TextDirection.rtl,
        child: NotificationListener<ScrollEndNotification>(
          onNotification: _readSelectedAndCallBackIfDateIsValid,
          child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.max,
              children: <Widget>[
                _monthColumnBuilder(),
                _yearColumnBuilder(),
              ]),
        ),
      );
    }
  }

  Jalali _getSelectedDate() {
    return Jalali(selectedYear, selectedMonth, selectedDay);
  }

  bool _readSelectedAndCallBackIfDateIsValid(
      ScrollEndNotification notification) {
    String notificationString = notification.toString();
    print(
        "scrollnotification from dayAndMonthPicker called notfication: $notificationString");
    if (!checkDateValidation()) {
      print(
          "jalaliCupertinoDatePicker wrong date selected, scrolled to correct one");
    }
    widget.onDateChanged(_getSelectedDate());
    return true;
  }

  bool checkDateValidation() {
    if (selectedYear == widget.minimumDate.year) {
      if (selectedMonth < widget.minimumDate.month) {
        scrollMonthColumnToItem(widget.minimumDate.month - 1);
        return false;
      } else if (selectedMonth == widget.minimumDate.month &&
          selectedDay < widget.minimumDate.day) {
        scrollDayColumnToItem(widget.minimumDate.day - 1);
        return false;
      }
    }
    if (selectedYear == widget.maximumDate.year) {
      if (widget.maximumDate.month < selectedMonth) {
        scrollMonthColumnToItem(widget.maximumDate.month - 1);
        return false;
      } else if (widget.maximumDate.month == selectedMonth &&
          widget.maximumDate.day < selectedDay) {
        scrollDayColumnToItem(widget.maximumDate.day - 1);
        return false;
      }
    }
    return true;
  }

  void scrollDayColumnToItem(int index) {
    SchedulerBinding.instance.addPostFrameCallback((Duration timestamp) {
      //i have no idea what the heck does this line, i found it in framework
      _dayController.animateToItem(index,
          curve: Curves.easeIn, duration: Duration(milliseconds: 500));
    });
  }

  void scrollMonthColumnToItem(int index) {
    SchedulerBinding.instance.addPostFrameCallback((Duration timestamp) {
      //i have no idea what the heck does this line, i found it in framework
      _monthController.animateToItem(index,
          curve: Curves.easeIn, duration: Duration(milliseconds: 500));
    });
  }

  Widget _monthColumnBuilder() {
    return Container(
      width: pickerWidth / numberOfColumns,
      color: _kBackgroundColor,
      child: CupertinoPicker(
        scrollController: _monthController,
        itemExtent: _kItemExtent,
        offAxisFraction: 0.0,
        useMagnifier: false,
        backgroundColor: _kBackgroundColor,
        onSelectedItemChanged: (int index) {
          print("JalaliCupertinoDatePicker selected month  is $index +1 ");
          selectedMonth = index + 1;
        },
        children: List<Widget>.generate(12, (int index) {
          var month = months[index];
          return Directionality(
            textDirection: TextDirection.rtl,
            child: Text(
              "$month",
              style: datePickerTextStyle,
            ),
          );
        }),
      ),
    );
  }

  Widget _yearColumnBuilder() {
    var minYear = widget.minimumDate.year;
    int numberOfyears = widget.maximumDate.year - minYear + 1;
    return Container(
      width: pickerWidth / numberOfColumns,
      color: _kBackgroundColor,
      child: CupertinoPicker(
        itemExtent: _kItemExtent,
        offAxisFraction: 0.0,
        useMagnifier: false,
        backgroundColor: _kBackgroundColor,
        onSelectedItemChanged: (int index) {
          print("JalaliCupertinoDatePicker  selected year is $index");
          selectedYear = index + widget.minimumDate.year;
        },
        children: List<Widget>.generate(numberOfyears, (int index) {
          int year = index + minYear;
          String yearInpersianDigit = StringHelpers.toPersianDigits(year.toString());
          return Text(
            yearInpersianDigit,
            style: datePickerTextStyle,
          );
        }),
      ),
    );
  }

  Widget _daysColumnBuilder() {
    return Container(
      width: pickerWidth / numberOfColumns,
      color: _kBackgroundColor,
      child: CupertinoPicker(
        scrollController: _dayController,
        itemExtent: _kItemExtent,
        offAxisFraction: 0.0,
        useMagnifier: false,
        backgroundColor: _kBackgroundColor,
        onSelectedItemChanged: (int index) {
          print("JalaliCupertinoDatePicker selected day is $index");
          selectedDay = index + 1;
        },
        children: List<Widget>.generate(30, (int index) {
          int day = index + 1;
          String dayInpersianDigit = StringHelpers.toPersianDigits(day.toString());
          return Text(
            dayInpersianDigit,
            style: datePickerTextStyle,
          );
        }),
      ),
    );
  }
}
