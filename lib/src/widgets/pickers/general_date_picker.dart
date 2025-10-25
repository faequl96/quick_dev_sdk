import 'dart:math' as math;
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:quick_dev_sdk/quick_dev_sdk.dart';

const Duration _monthScrollDuration = Duration(milliseconds: 200);

const double _dayPickerRowHeight = 54.0;
const int _maxDayPickerRowCount = 6;
const double _monthPickerHorizontalPadding = 8.0;

const int _yearPickerColumnCount = 3;
const double _yearPickerPadding = 16.0;
const double _yearPickerRowHeight = 52.0;
const double _yearPickerRowSpacing = 8.0;

const double _subHeaderHeight = 52.0;
const double _monthNavButtonsWidth = 108.0;

class GeneralDatePicker extends StatefulWidget {
  const GeneralDatePicker({
    super.key,
    this.initialDate,
    required this.firstDate,
    required this.lastDate,
    this.currentDate,
    this.holidays = const [],
    required this.onDateChanged,
    this.onDisplayedMonthChanged,
    this.initialCalendarMode = DatePickerMode.day,
    this.selectableDayPredicate,
  });

  final DateTime? initialDate;
  final DateTime firstDate;
  final DateTime lastDate;
  final DateTime? currentDate;
  final List<Holiday> holidays;
  final ValueChanged<DateTime> onDateChanged;
  final ValueChanged<DateTime>? onDisplayedMonthChanged;
  final DatePickerMode initialCalendarMode;
  final SelectableDayPredicate? selectableDayPredicate;

  @override
  State<GeneralDatePicker> createState() => _GeneralDatePickerState();
}

class _GeneralDatePickerState extends State<GeneralDatePicker> {
  bool _announcedInitialDate = false;
  late DatePickerMode _mode;
  late DateTime _currentDisplayedMonthDate;
  late DateTime? _selectedDate;
  final GlobalKey _monthPickerKey = GlobalKey();
  final GlobalKey _yearPickerKey = GlobalKey();
  late MaterialLocalizations _localizations;
  late TextDirection _textDirection;
  List<Holiday> _filteredMounthHoliday = [];

  @override
  void initState() {
    super.initState();
    _mode = widget.initialCalendarMode;
    // _currentDisplayedMonthDate =
    //     DateTime(widget.initialDate.year, widget.initialDate.month);
    _currentDisplayedMonthDate = widget.initialDate ?? DateTime.now();
    _selectedDate = widget.initialDate;

    _filteredMounthHoliday = widget.holidays
        .where(
          (element) =>
              DateTime(element.date.year, element.date.month) ==
              DateTime(_currentDisplayedMonthDate.year, _currentDisplayedMonthDate.month),
        )
        .toList();
  }

  @override
  void didUpdateWidget(GeneralDatePicker oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialCalendarMode != oldWidget.initialCalendarMode) {
      _mode = widget.initialCalendarMode;
    }
    if (!DateUtils.isSameDay(widget.initialDate, oldWidget.initialDate)) {
      // _currentDisplayedMonthDate =
      //     DateTime(widget.initialDate.year, widget.initialDate.month);
      // _currentDisplayedMonthDate = DateTime(2024, 2);
      _currentDisplayedMonthDate = widget.initialDate ?? DateTime.now();
      _selectedDate = widget.initialDate;
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    assert(debugCheckHasMaterial(context));
    assert(debugCheckHasMaterialLocalizations(context));
    assert(debugCheckHasDirectionality(context));
    _localizations = MaterialLocalizations.of(context);
    _textDirection = Directionality.of(context);
    if (!_announcedInitialDate) {
      _announcedInitialDate = true;
      SemanticsService.announce(_localizations.formatFullDate(_selectedDate ?? DateTime.now()), _textDirection);
    }
  }

  void _vibrate() {
    switch (Theme.of(context).platform) {
      case TargetPlatform.android:
      case TargetPlatform.fuchsia:
      case TargetPlatform.linux:
      case TargetPlatform.windows:
        HapticFeedback.vibrate();
        break;
      case TargetPlatform.iOS:
      case TargetPlatform.macOS:
        break;
    }
  }

  void _handleModeChanged(DatePickerMode mode) {
    _vibrate();
    setState(() {
      _mode = mode;
      if (_mode == DatePickerMode.day) {
        SemanticsService.announce(_localizations.formatMonthYear(_selectedDate ?? DateTime.now()), _textDirection);
      } else {
        SemanticsService.announce(_localizations.formatYear(_selectedDate ?? DateTime.now()), _textDirection);
      }
    });
  }

  void _handleMonthChanged(DateTime date) {
    setState(() {
      if (_currentDisplayedMonthDate.year != date.year || _currentDisplayedMonthDate.month != date.month) {
        _currentDisplayedMonthDate = DateTime(date.year, date.month);
        widget.onDisplayedMonthChanged?.call(_currentDisplayedMonthDate);

        _filteredMounthHoliday = widget.holidays
            .where(
              (element) =>
                  DateTime(element.date.year, element.date.month) ==
                  DateTime(_currentDisplayedMonthDate.year, _currentDisplayedMonthDate.month),
            )
            .toList();
      }
    });
  }

  void _handleYearChanged(DateTime value) {
    _vibrate();

    if (value.isBefore(widget.firstDate)) {
      value = widget.firstDate;
    } else if (value.isAfter(widget.lastDate)) {
      value = widget.lastDate;
    }

    setState(() {
      _mode = DatePickerMode.day;
      _handleMonthChanged(value);
    });
  }

  void _handleDayChanged(DateTime value) {
    _vibrate();
    setState(() {
      _selectedDate = value;
      widget.onDateChanged(_selectedDate ?? DateTime.now());
    });
  }

  Widget _buildPicker() {
    switch (_mode) {
      case DatePickerMode.day:
        return _MonthPicker(
          key: _monthPickerKey,
          initialMonth: _currentDisplayedMonthDate,
          currentDate: widget.currentDate ?? DateTime.now(),
          firstDate: widget.firstDate,
          lastDate: widget.lastDate,
          selectedDate: _selectedDate,
          holidays: widget.holidays,
          onChanged: _handleDayChanged,
          onDisplayedMonthChanged: _handleMonthChanged,
          selectableDayPredicate: widget.selectableDayPredicate,
        );
      case DatePickerMode.year:
        return Padding(
          padding: const EdgeInsets.only(top: _subHeaderHeight),
          child: YearPicker(
            key: _yearPickerKey,
            currentDate: widget.currentDate ?? DateTime.now(),
            firstDate: widget.firstDate,
            lastDate: widget.lastDate,
            initialDate: _currentDisplayedMonthDate,
            selectedDate: _selectedDate,
            onChanged: _handleYearChanged,
          ),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    assert(debugCheckHasMaterial(context));
    assert(debugCheckHasMaterialLocalizations(context));
    assert(debugCheckHasDirectionality(context));
    return Stack(
      children: [
        Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(height: 450, child: _buildPicker()),
            ..._filteredMounthHoliday.map((item) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 16),
                child: Row(
                  children: [
                    const Icon(Icons.circle, color: Colors.red, size: 8),
                    const SizedBox(width: 10),
                    Text(
                      '${_localizations.formatShortMonthDay(item.date)}, ',
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.red),
                    ),
                    Text(
                      item.description,
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.red),
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
        _DatePickerModeToggleButton(
          mode: _mode,
          title: _localizations.formatMonthYear(_currentDisplayedMonthDate),
          onTitlePressed: () {
            _handleModeChanged(_mode == DatePickerMode.day ? DatePickerMode.year : DatePickerMode.day);
          },
        ),
      ],
    );
  }
}

class _DatePickerModeToggleButton extends StatefulWidget {
  const _DatePickerModeToggleButton({required this.mode, required this.title, required this.onTitlePressed});

  final DatePickerMode mode;
  final String title;
  final VoidCallback onTitlePressed;

  @override
  _DatePickerModeToggleButtonState createState() => _DatePickerModeToggleButtonState();
}

class _DatePickerModeToggleButtonState extends State<_DatePickerModeToggleButton> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      value: widget.mode == DatePickerMode.year ? 0.5 : 0,
      upperBound: 0.5,
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
  }

  @override
  void didUpdateWidget(_DatePickerModeToggleButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.mode == widget.mode) {
      return;
    }

    if (widget.mode == DatePickerMode.year) {
      _controller.forward();
    } else {
      _controller.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final TextTheme textTheme = Theme.of(context).textTheme;
    final Color controlColor = colorScheme.onSurface.withValues(alpha: 0.60);

    return Container(
      padding: const EdgeInsetsDirectional.only(start: 16, end: 4),
      height: _subHeaderHeight,
      child: Row(
        children: <Widget>[
          Flexible(
            child: Semantics(
              label: MaterialLocalizations.of(context).selectYearSemanticsLabel,
              excludeSemantics: true,
              button: true,
              child: SizedBox(
                height: _subHeaderHeight,
                child: InkWell(
                  onTap: widget.onTitlePressed,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Row(
                      children: <Widget>[
                        Flexible(
                          child: Text(
                            widget.title,
                            overflow: TextOverflow.ellipsis,
                            style: textTheme.titleSmall?.copyWith(color: controlColor),
                          ),
                        ),
                        RotationTransition(
                          turns: _controller,
                          child: Icon(Icons.arrow_drop_down, color: controlColor),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          if (widget.mode == DatePickerMode.day) const SizedBox(width: _monthNavButtonsWidth),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}

class _MonthPicker extends StatefulWidget {
  const _MonthPicker({
    super.key,
    required this.initialMonth,
    required this.currentDate,
    required this.firstDate,
    required this.lastDate,
    this.selectedDate,
    required this.holidays,
    required this.onChanged,
    required this.onDisplayedMonthChanged,
    this.selectableDayPredicate,
  });

  final DateTime initialMonth;
  final DateTime currentDate;
  final DateTime firstDate;
  final DateTime lastDate;
  final DateTime? selectedDate;
  final List<Holiday> holidays;
  final ValueChanged<DateTime> onChanged;
  final ValueChanged<DateTime> onDisplayedMonthChanged;
  final SelectableDayPredicate? selectableDayPredicate;

  @override
  _MonthPickerState createState() => _MonthPickerState();
}

class _MonthPickerState extends State<_MonthPicker> {
  final GlobalKey _pageViewKey = GlobalKey();
  late DateTime _currentMonth;
  late PageController _pageController;
  late MaterialLocalizations _localizations;
  late TextDirection _textDirection;
  Map<ShortcutActivator, Intent>? _shortcutMap;
  Map<Type, Action<Intent>>? _actionMap;
  late FocusNode _dayGridFocus;
  DateTime? _focusedDay;

  @override
  void initState() {
    super.initState();
    _currentMonth = widget.initialMonth;
    _pageController = PageController(initialPage: DateUtils.monthDelta(widget.firstDate, _currentMonth));
    _shortcutMap = const <ShortcutActivator, Intent>{
      SingleActivator(LogicalKeyboardKey.arrowLeft): DirectionalFocusIntent(TraversalDirection.left),
      SingleActivator(LogicalKeyboardKey.arrowRight): DirectionalFocusIntent(TraversalDirection.right),
      SingleActivator(LogicalKeyboardKey.arrowDown): DirectionalFocusIntent(TraversalDirection.down),
      SingleActivator(LogicalKeyboardKey.arrowUp): DirectionalFocusIntent(TraversalDirection.up),
    };
    _actionMap = <Type, Action<Intent>>{
      NextFocusIntent: CallbackAction<NextFocusIntent>(onInvoke: _handleGridNextFocus),
      PreviousFocusIntent: CallbackAction<PreviousFocusIntent>(onInvoke: _handleGridPreviousFocus),
      DirectionalFocusIntent: CallbackAction<DirectionalFocusIntent>(onInvoke: _handleDirectionFocus),
    };
    _dayGridFocus = FocusNode(debugLabel: 'Day Grid');
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _localizations = MaterialLocalizations.of(context);
    _textDirection = Directionality.of(context);
  }

  @override
  void didUpdateWidget(_MonthPicker oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialMonth != oldWidget.initialMonth && widget.initialMonth != _currentMonth) {
      WidgetsBinding.instance.addPostFrameCallback((Duration timeStamp) => _showMonth(widget.initialMonth, jump: true));
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    _dayGridFocus.dispose();
    super.dispose();
  }

  void _handleDateSelected(DateTime selectedDate) {
    _focusedDay = selectedDate;
    widget.onChanged(selectedDate);
  }

  void _handleMonthPageChanged(int monthPage) {
    setState(() {
      final DateTime monthDate = DateUtils.addMonthsToMonthDate(widget.firstDate, monthPage);
      if (!DateUtils.isSameMonth(_currentMonth, monthDate)) {
        _currentMonth = DateTime(monthDate.year, monthDate.month);
        widget.onDisplayedMonthChanged(_currentMonth);
        if (_focusedDay != null && !DateUtils.isSameMonth(_focusedDay, _currentMonth)) {
          _focusedDay = _focusableDayForMonth(_currentMonth, _focusedDay!.day);
        }
        SemanticsService.announce(_localizations.formatMonthYear(_currentMonth), _textDirection);
      }
    });
  }

  DateTime? _focusableDayForMonth(DateTime month, int preferredDay) {
    final int daysInMonth = DateUtils.getDaysInMonth(month.year, month.month);

    if (preferredDay <= daysInMonth) {
      final DateTime newFocus = DateTime(month.year, month.month, preferredDay);
      if (_isSelectable(newFocus)) {
        return newFocus;
      }
    }

    for (int day = 1; day <= daysInMonth; day++) {
      final DateTime newFocus = DateTime(month.year, month.month, day);
      if (_isSelectable(newFocus)) {
        return newFocus;
      }
    }
    return null;
  }

  void _handleNextMonth() {
    if (!_isDisplayingLastMonth) {
      _pageController.nextPage(duration: _monthScrollDuration, curve: Curves.ease);
    }
  }

  void _handlePreviousMonth() {
    if (!_isDisplayingFirstMonth) {
      _pageController.previousPage(duration: _monthScrollDuration, curve: Curves.ease);
    }
  }

  void _showMonth(DateTime month, {bool jump = false}) {
    final int monthPage = DateUtils.monthDelta(widget.firstDate, month);
    if (jump) {
      _pageController.jumpToPage(monthPage);
    } else {
      _pageController.animateToPage(monthPage, duration: _monthScrollDuration, curve: Curves.ease);
    }
  }

  bool get _isDisplayingFirstMonth {
    return !_currentMonth.isAfter(DateTime(widget.firstDate.year, widget.firstDate.month));
  }

  bool get _isDisplayingLastMonth {
    return !_currentMonth.isBefore(DateTime(widget.lastDate.year, widget.lastDate.month));
  }

  void _handleGridFocusChange(bool focused) {
    setState(() {
      if (focused && _focusedDay == null) {
        if (DateUtils.isSameMonth(widget.selectedDate, _currentMonth)) {
          _focusedDay = widget.selectedDate;
        } else if (DateUtils.isSameMonth(widget.currentDate, _currentMonth)) {
          _focusedDay = _focusableDayForMonth(_currentMonth, widget.currentDate.day);
        } else {
          _focusedDay = _focusableDayForMonth(_currentMonth, 1);
        }
      }
    });
  }

  void _handleGridNextFocus(NextFocusIntent intent) {
    _dayGridFocus.requestFocus();
    _dayGridFocus.nextFocus();
  }

  void _handleGridPreviousFocus(PreviousFocusIntent intent) {
    _dayGridFocus.requestFocus();
    _dayGridFocus.previousFocus();
  }

  void _handleDirectionFocus(DirectionalFocusIntent intent) {
    assert(_focusedDay != null);
    setState(() {
      final DateTime? nextDate = _nextDateInDirection(_focusedDay!, intent.direction);
      if (nextDate != null) {
        _focusedDay = nextDate;
        if (!DateUtils.isSameMonth(_focusedDay, _currentMonth)) {
          _showMonth(_focusedDay!);
        }
      }
    });
  }

  static const Map<TraversalDirection, int> _directionOffset = <TraversalDirection, int>{
    TraversalDirection.up: -DateTime.daysPerWeek,
    TraversalDirection.right: 1,
    TraversalDirection.down: DateTime.daysPerWeek,
    TraversalDirection.left: -1,
  };

  int _dayDirectionOffset(TraversalDirection traversalDirection, TextDirection textDirection) {
    if (textDirection == TextDirection.rtl) {
      if (traversalDirection == TraversalDirection.left) {
        traversalDirection = TraversalDirection.right;
      } else if (traversalDirection == TraversalDirection.right) {
        traversalDirection = TraversalDirection.left;
      }
    }
    return _directionOffset[traversalDirection]!;
  }

  DateTime? _nextDateInDirection(DateTime date, TraversalDirection direction) {
    final TextDirection textDirection = Directionality.of(context);
    DateTime nextDate = DateUtils.addDaysToDate(date, _dayDirectionOffset(direction, textDirection));
    while (!nextDate.isBefore(widget.firstDate) && !nextDate.isAfter(widget.lastDate)) {
      if (_isSelectable(nextDate)) {
        return nextDate;
      }
      nextDate = DateUtils.addDaysToDate(nextDate, _dayDirectionOffset(direction, textDirection));
    }
    return null;
  }

  bool _isSelectable(DateTime date) {
    return widget.selectableDayPredicate == null || widget.selectableDayPredicate!.call(date);
  }

  Widget _buildItems(BuildContext context, int index) {
    final DateTime month = DateUtils.addMonthsToMonthDate(widget.firstDate, index);
    return _DayPicker(
      key: ValueKey<DateTime>(month),
      selectedDate: widget.selectedDate,
      currentDate: widget.currentDate,
      onChanged: _handleDateSelected,
      firstDate: widget.firstDate,
      lastDate: widget.lastDate,
      holidays: widget.holidays,
      displayedMonth: month,
      selectableDayPredicate: widget.selectableDayPredicate,
    );
  }

  @override
  Widget build(BuildContext context) {
    final Color controlColor = Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.60);

    return Semantics(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsetsDirectional.only(start: 16, end: 4),
            height: _subHeaderHeight,
            child: Row(
              children: <Widget>[
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.chevron_left),
                  color: controlColor,
                  tooltip: _isDisplayingFirstMonth ? null : _localizations.previousMonthTooltip,
                  onPressed: _isDisplayingFirstMonth ? null : _handlePreviousMonth,
                ),
                IconButton(
                  icon: const Icon(Icons.chevron_right),
                  color: controlColor,
                  tooltip: _isDisplayingLastMonth ? null : _localizations.nextMonthTooltip,
                  onPressed: _isDisplayingLastMonth ? null : _handleNextMonth,
                ),
              ],
            ),
          ),
          Flexible(
            child: FocusableActionDetector(
              shortcuts: _shortcutMap,
              actions: _actionMap,
              focusNode: _dayGridFocus,
              onFocusChange: _handleGridFocusChange,
              child: _FocusedDate(
                date: _dayGridFocus.hasFocus ? _focusedDay : null,
                child: PageView.builder(
                  key: _pageViewKey,
                  controller: _pageController,
                  itemBuilder: _buildItems,
                  itemCount: DateUtils.monthDelta(widget.firstDate, widget.lastDate) + 1,
                  onPageChanged: _handleMonthPageChanged,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FocusedDate extends InheritedWidget {
  const _FocusedDate({required super.child, this.date});

  final DateTime? date;

  @override
  bool updateShouldNotify(_FocusedDate oldWidget) {
    return !DateUtils.isSameDay(date, oldWidget.date);
  }

  static DateTime? of(BuildContext context) {
    final _FocusedDate? focusedDate = context.dependOnInheritedWidgetOfExactType<_FocusedDate>();
    return focusedDate?.date;
  }
}

class _DayPicker extends StatefulWidget {
  const _DayPicker({
    super.key,
    required this.currentDate,
    required this.displayedMonth,
    required this.firstDate,
    required this.lastDate,
    this.selectedDate,
    required this.holidays,
    required this.onChanged,
    this.selectableDayPredicate,
  });

  final DateTime? selectedDate;
  final DateTime currentDate;
  final ValueChanged<DateTime> onChanged;
  final DateTime firstDate;
  final DateTime lastDate;
  final List<Holiday> holidays;
  final DateTime displayedMonth;
  final SelectableDayPredicate? selectableDayPredicate;

  @override
  _DayPickerState createState() => _DayPickerState();
}

class _DayPickerState extends State<_DayPicker> {
  late List<FocusNode> _dayFocusNodes;

  @override
  void initState() {
    super.initState();
    final int daysInMonth = DateUtils.getDaysInMonth(widget.displayedMonth.year, widget.displayedMonth.month);
    _dayFocusNodes = List<FocusNode>.generate(
      daysInMonth,
      (int index) => FocusNode(skipTraversal: true, debugLabel: 'Day ${index + 1}'),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final DateTime? focusedDate = _FocusedDate.of(context);
    if (focusedDate != null && DateUtils.isSameMonth(widget.displayedMonth, focusedDate)) {
      _dayFocusNodes[focusedDate.day - 1].requestFocus();
    }
  }

  @override
  void dispose() {
    for (final FocusNode node in _dayFocusNodes) {
      node.dispose();
    }
    super.dispose();
  }

  List<Widget> _dayHeaders(List<TextStyle?> headerStyle, MaterialLocalizations localizations) {
    final List<Widget> result = <Widget>[];
    for (int i = localizations.firstDayOfWeekIndex; true; i = (i + 1) % 7) {
      final String weekday = localizations.narrowWeekdays[i];
      result.add(
        ExcludeSemantics(
          child: Center(
            child: Text(
              weekday,
              style: (weekday == 'S' && i == 0) || (weekday == 'M' && i == 0)
                  ? headerStyle[1]
                  : (weekday == 'F' && i == 5) || (weekday == 'J' && i == 5)
                  ? headerStyle[2]
                  : headerStyle[0],
            ),
          ),
        ),
      );
      if (i == (localizations.firstDayOfWeekIndex - 1) % 7) {
        break;
      }
    }
    return result;
  }

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final MaterialLocalizations localizations = MaterialLocalizations.of(context);
    final TextTheme textTheme = Theme.of(context).textTheme;
    final List<TextStyle> headerStyle = [
      const TextStyle(fontWeight: FontWeight.bold, color: Colors.black87),
      TextStyle(fontWeight: FontWeight.bold, color: Colors.red[600]),
      TextStyle(fontWeight: FontWeight.bold, color: Colors.greenAccent[700]),
    ];
    final TextStyle dayStyle = textTheme.bodySmall!;
    final Color enabledDayColor = colorScheme.onSurface.withValues(alpha: 0.88);
    final Color disabledDayColor = colorScheme.onSurface.withValues(alpha: 0.58);
    const Color selectedDayColor = Colors.white;
    final Color selectedDayBackground = const Color(0xFF09AB81);
    final Color todayColor = Colors.greenAccent[700]!;
    final Color sundayColor = Colors.red[600]!;
    final Color sundayColorDisabled = Colors.red[600]!.withValues(alpha: 0.7);
    final Color holidayColor = Colors.red[600]!;
    final Color holidayColorDisabled = Colors.red[600]!.withValues(alpha: 0.7);

    const FontWeight enabledDayFontWeight = FontWeight.bold;
    const FontWeight disabledDayFontWeight = FontWeight.normal;

    const double regularDayFontSize = 2;
    const double todayFontSize = 3;

    final int year = widget.displayedMonth.year;
    final int month = widget.displayedMonth.month;

    final int daysInMonth = DateUtils.getDaysInMonth(year, month);
    final int dayOffset = DateUtils.firstDayOffset(year, month, localizations);

    final List<Widget> dayItems = _dayHeaders(headerStyle, localizations);

    DateTime findLastDateOfTheWeek(DateTime dateTime) {
      return dateTime.add(Duration(days: DateTime.daysPerWeek - dateTime.weekday));
    }

    int day = -dayOffset;
    while (day < daysInMonth) {
      day++;
      if (day < 1) {
        dayItems.add(const SizedBox.shrink());
      } else {
        DateTime firstDayMin1 = DateTime(widget.firstDate.year, widget.firstDate.month, widget.firstDate.day);
        final DateTime dayToBuild = DateTime(year, month, day);
        final bool isDisabled =
            dayToBuild.isAfter(widget.lastDate) ||
            dayToBuild.isBefore(firstDayMin1) ||
            (widget.selectableDayPredicate != null && !widget.selectableDayPredicate!(dayToBuild));
        final bool isSelectedDay = DateUtils.isSameDay(widget.selectedDate, dayToBuild);
        final bool isToday = DateUtils.isSameDay(widget.currentDate, dayToBuild);
        final bool isSunday = findLastDateOfTheWeek(dayToBuild).day == day;
        final List<DateTime?> holidaysDate = widget.holidays.map((e) => e.date).toList();
        final bool isHoliday = holidaysDate.contains(dayToBuild);

        BoxDecoration? decoration;
        Color dayColor = enabledDayColor;
        FontWeight dayFontWeight = enabledDayFontWeight;
        double dayFontSize = regularDayFontSize;

        if (isSelectedDay) {
          dayColor = selectedDayColor;
          decoration = BoxDecoration(color: selectedDayBackground, shape: BoxShape.circle);
        } else if (isToday) {
          dayColor = todayColor;
          dayFontSize = todayFontSize;
        } else if (isHoliday && isDisabled == true) {
          dayColor = holidayColorDisabled;
          dayFontWeight = disabledDayFontWeight;
        } else if (isHoliday && isDisabled == false) {
          dayColor = holidayColor;
        } else if (isSunday && isDisabled == true) {
          dayColor = sundayColorDisabled;
          dayFontWeight = disabledDayFontWeight;
        } else if (isSunday && isDisabled == false) {
          dayColor = sundayColor;
        } else if (isDisabled) {
          dayColor = disabledDayColor;
          dayFontWeight = disabledDayFontWeight;
        }

        Widget dayWidget = Container(
          decoration: decoration,
          child: Center(
            child: Text(
              localizations.formatDecimal(day),
              style: dayStyle.apply(
                color: dayColor,
                fontWeightDelta: dayFontWeight == FontWeight.bold ? 2 : 1,
                fontSizeDelta: dayFontSize,
              ),
            ),
          ),
        );

        if (isToday) {
          dayWidget = Container(
            decoration: decoration,
            child: Stack(
              alignment: AlignmentDirectional.bottomCenter,
              children: [
                SizedBox(
                  height: double.maxFinite,
                  child: Center(
                    child: Text(
                      localizations.formatDecimal(day),
                      style: dayStyle.apply(
                        color: dayColor,
                        fontWeightDelta: dayFontWeight == FontWeight.bold ? 2 : 1,
                        fontSizeDelta: dayFontSize,
                      ),
                    ),
                  ),
                ),
                if (!isSelectedDay)
                  Text(
                    Localizations.localeOf(context).toString() == 'id_ID' ? 'Hari ini' : 'Today',
                    style: TextStyle(fontWeight: FontWeight.bold, color: dayColor, fontSize: 12),
                  ),
              ],
            ),
          );
        }

        if (isHoliday) {
          dayWidget = Container(
            decoration: decoration,
            child: Stack(
              alignment: AlignmentDirectional.bottomCenter,
              children: [
                SizedBox(
                  height: double.maxFinite,
                  child: Center(
                    child: Text(
                      localizations.formatDecimal(day),
                      style: dayStyle.apply(
                        color: dayColor,
                        fontWeightDelta: dayFontWeight == FontWeight.bold ? 2 : 1,
                        fontSizeDelta: dayFontSize,
                      ),
                    ),
                  ),
                ),
                if (!isSelectedDay)
                  if (isToday)
                    Row(
                      children: [
                        Icon(Icons.circle, color: dayColor, size: 6),
                        const SizedBox(width: 2),
                        Text(
                          Localizations.localeOf(context).toString() == 'id_ID' ? 'Hari ini' : 'Today',
                          style: dayStyle.apply(color: dayColor, fontSizeDelta: 0.4),
                        ),
                      ],
                    )
                  else
                    Positioned(bottom: 6, child: Icon(Icons.circle, color: dayColor, size: 7)),
              ],
            ),
          );
        }

        if (isDisabled) {
          dayWidget = ExcludeSemantics(child: dayWidget);
        } else {
          dayWidget = HoveredBackground(
            boxShape: isToday ? null : BoxShape.circle,
            hoveredColor: ColorConverter.lighten(const Color(0xFF09AB81), 90),
            child: InkResponse(
              focusNode: _dayFocusNodes[day - 1],
              onTap: () => widget.onChanged(dayToBuild),
              radius: _dayPickerRowHeight / 2 + 4,
              splashColor: selectedDayBackground.withValues(alpha: 0.38),
              child: Semantics(
                label: '${localizations.formatDecimal(day)}, ${localizations.formatFullDate(dayToBuild)}',
                selected: isSelectedDay,
                excludeSemantics: true,
                child: dayWidget,
              ),
            ),
          );
        }

        dayItems.add(dayWidget);
      }
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: _monthPickerHorizontalPadding),
      child: GridView.custom(
        physics: const ClampingScrollPhysics(),
        gridDelegate: _dayPickerGridDelegate,
        childrenDelegate: SliverChildListDelegate(dayItems, addRepaintBoundaries: false),
      ),
    );
  }
}

class _DayPickerGridDelegate extends SliverGridDelegate {
  const _DayPickerGridDelegate();

  @override
  SliverGridLayout getLayout(SliverConstraints constraints) {
    const int columnCount = DateTime.daysPerWeek;
    final double tileWidth = constraints.crossAxisExtent / columnCount;
    final double tileHeight = math.min(_dayPickerRowHeight, constraints.viewportMainAxisExtent / (_maxDayPickerRowCount + 1));
    return SliverGridRegularTileLayout(
      childCrossAxisExtent: tileWidth,
      childMainAxisExtent: tileHeight,
      crossAxisCount: columnCount,
      crossAxisStride: tileWidth,
      mainAxisStride: tileHeight,
      reverseCrossAxis: axisDirectionIsReversed(constraints.crossAxisDirection),
    );
  }

  @override
  bool shouldRelayout(_DayPickerGridDelegate oldDelegate) => false;
}

const _DayPickerGridDelegate _dayPickerGridDelegate = _DayPickerGridDelegate();

class YearPicker extends StatefulWidget {
  const YearPicker({
    super.key,
    required this.currentDate,
    required this.firstDate,
    required this.lastDate,
    required this.initialDate,
    this.selectedDate,
    required this.onChanged,
    this.dragStartBehavior = DragStartBehavior.start,
  });

  final DateTime currentDate;
  final DateTime firstDate;
  final DateTime lastDate;
  final DateTime initialDate;
  final DateTime? selectedDate;
  final ValueChanged<DateTime> onChanged;
  final DragStartBehavior dragStartBehavior;

  @override
  State<YearPicker> createState() => _YearPickerState();
}

class _YearPickerState extends State<YearPicker> {
  late ScrollController _scrollController;
  static const int minYears = 18;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController(initialScrollOffset: _scrollOffsetForYear(widget.selectedDate ?? DateTime.now()));
  }

  @override
  void didUpdateWidget(YearPicker oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.selectedDate != oldWidget.selectedDate) {
      _scrollController.jumpTo(_scrollOffsetForYear(widget.selectedDate ?? DateTime.now()));
    }
  }

  double _scrollOffsetForYear(DateTime date) {
    final int initialYearIndex = date.year - widget.firstDate.year;
    final int initialYearRow = initialYearIndex ~/ _yearPickerColumnCount;
    final int centeredYearRow = initialYearRow - 2;
    return _itemCount < minYears ? 0 : centeredYearRow * _yearPickerRowHeight;
  }

  Widget _buildYearItem(BuildContext context, int index) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final TextTheme textTheme = Theme.of(context).textTheme;

    final int offset = _itemCount < minYears ? (minYears - _itemCount) ~/ 2 : 0;
    final int year = widget.firstDate.year + index - offset;
    final bool isSelected = year == widget.initialDate.year;
    // print(
    //   "$year, $isSelected, ${widget.selectedDate}",
    // );
    final bool isCurrentYear = year == widget.currentDate.year;
    final bool isDisabled = year < widget.firstDate.year || year > widget.lastDate.year;
    const double decorationHeight = 36.0;
    const double decorationWidth = 72.0;

    final Color textColor;
    if (isSelected) {
      textColor = colorScheme.onPrimary;
    } else if (isDisabled) {
      textColor = colorScheme.onSurface.withValues(alpha: 0.38);
    } else if (isCurrentYear) {
      textColor = Colors.greenAccent[700]!;
    } else {
      textColor = colorScheme.onSurface.withValues(alpha: 0.87);
    }

    final FontWeight fontWeight;
    if (isDisabled) {
      fontWeight = FontWeight.normal;
    } else {
      fontWeight = FontWeight.bold;
    }
    final TextStyle? itemStyle = textTheme.bodyLarge?.apply(
      color: textColor,
      fontWeightDelta: fontWeight == FontWeight.bold ? 2 : 1,
    );

    BoxDecoration? decoration;
    if (isSelected) {
      decoration = BoxDecoration(color: colorScheme.primary, borderRadius: BorderRadius.circular(decorationHeight / 2));
    }
    // else if (isCurrentYear && !isDisabled) {
    //   decoration = BoxDecoration(
    //     border: Border.all(
    //       color: colorScheme.primary,
    //     ),
    //     borderRadius: BorderRadius.circular(decorationHeight / 2),
    //   );
    // }

    Widget yearItem = Center(
      child: Container(
        decoration: decoration,
        height: decorationHeight,
        width: decorationWidth,
        child: Center(
          child: Semantics(
            selected: isSelected,
            button: true,
            child: Text(year.toString(), style: itemStyle),
          ),
        ),
      ),
    );

    if (isDisabled) {
      yearItem = ExcludeSemantics(child: yearItem);
    } else {
      yearItem = InkWell(
        key: ValueKey<int>(year),
        onTap: () => widget.onChanged(DateTime(year, widget.initialDate.month)),
        child: yearItem,
      );
    }

    return yearItem;
  }

  int get _itemCount {
    return widget.lastDate.year - widget.firstDate.year + 1;
  }

  @override
  Widget build(BuildContext context) {
    assert(debugCheckHasMaterial(context));
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Divider(),
        Flexible(
          child: GridView.builder(
            controller: _scrollController,
            dragStartBehavior: widget.dragStartBehavior,
            gridDelegate: _yearPickerGridDelegate,
            itemBuilder: _buildYearItem,
            itemCount: math.max(_itemCount, minYears),
            padding: const EdgeInsets.symmetric(horizontal: _yearPickerPadding),
          ),
        ),
        const Divider(),
      ],
    );
  }
}

class _YearPickerGridDelegate extends SliverGridDelegate {
  const _YearPickerGridDelegate();

  @override
  SliverGridLayout getLayout(SliverConstraints constraints) {
    final double tileWidth =
        (constraints.crossAxisExtent - (_yearPickerColumnCount - 1) * _yearPickerRowSpacing) / _yearPickerColumnCount;
    return SliverGridRegularTileLayout(
      childCrossAxisExtent: tileWidth,
      childMainAxisExtent: _yearPickerRowHeight,
      crossAxisCount: _yearPickerColumnCount,
      crossAxisStride: tileWidth + _yearPickerRowSpacing,
      mainAxisStride: _yearPickerRowHeight,
      reverseCrossAxis: axisDirectionIsReversed(constraints.crossAxisDirection),
    );
  }

  @override
  bool shouldRelayout(_YearPickerGridDelegate oldDelegate) => false;
}

const _YearPickerGridDelegate _yearPickerGridDelegate = _YearPickerGridDelegate();

class Holiday {
  const Holiday({required this.date, required this.description});

  final DateTime date;
  final String description;
}
