// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database.dart';

// ignore_for_file: type=lint
class $BreakTypesTable extends BreakTypes
    with TableInfo<$BreakTypesTable, BreakType> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $BreakTypesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 60,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _descriptionMeta = const VerificationMeta(
    'description',
  );
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
    'description',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _colorValueMeta = const VerificationMeta(
    'colorValue',
  );
  @override
  late final GeneratedColumn<int> colorValue = GeneratedColumn<int>(
    'color_value',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _isDefaultMeta = const VerificationMeta(
    'isDefault',
  );
  @override
  late final GeneratedColumn<bool> isDefault = GeneratedColumn<bool>(
    'is_default',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_default" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _isActiveMeta = const VerificationMeta(
    'isActive',
  );
  @override
  late final GeneratedColumn<bool> isActive = GeneratedColumn<bool>(
    'is_active',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_active" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _alarmEnabledMeta = const VerificationMeta(
    'alarmEnabled',
  );
  @override
  late final GeneratedColumn<bool> alarmEnabled = GeneratedColumn<bool>(
    'alarm_enabled',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("alarm_enabled" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _expectedDurationMinutesMeta =
      const VerificationMeta('expectedDurationMinutes');
  @override
  late final GeneratedColumn<int> expectedDurationMinutes =
      GeneratedColumn<int>(
        'expected_duration_minutes',
        aliasedName,
        false,
        type: DriftSqlType.int,
        requiredDuringInsert: false,
        defaultValue: const Constant(15),
      );
  @override
  late final GeneratedColumnWithTypeConverter<AlarmSound, String> alarmSound =
      GeneratedColumn<String>(
        'alarm_sound',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
        defaultValue: Constant(AlarmSound.notification.name),
      ).withConverter<AlarmSound>($BreakTypesTable.$converteralarmSound);
  static const VerificationMeta _vibrationEnabledMeta = const VerificationMeta(
    'vibrationEnabled',
  );
  @override
  late final GeneratedColumn<bool> vibrationEnabled = GeneratedColumn<bool>(
    'vibration_enabled',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("vibration_enabled" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  @override
  late final GeneratedColumnWithTypeConverter<AlarmAlertStyle, String>
  alertStyle = GeneratedColumn<String>(
    'alert_style',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: Constant(AlarmAlertStyle.headsUp.name),
  ).withConverter<AlarmAlertStyle>($BreakTypesTable.$converteralertStyle);
  @override
  late final GeneratedColumnWithTypeConverter<ReminderBehaviour, String>
  reminderBehaviour =
      GeneratedColumn<String>(
        'reminder_behaviour',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
        defaultValue: Constant(ReminderBehaviour.once.name),
      ).withConverter<ReminderBehaviour>(
        $BreakTypesTable.$converterreminderBehaviour,
      );
  static const VerificationMeta _repeatIntervalMinutesMeta =
      const VerificationMeta('repeatIntervalMinutes');
  @override
  late final GeneratedColumn<int> repeatIntervalMinutes = GeneratedColumn<int>(
    'repeat_interval_minutes',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(5),
  );
  static const VerificationMeta _midBreakAlarmMinutesMeta =
      const VerificationMeta('midBreakAlarmMinutes');
  @override
  late final GeneratedColumn<String> midBreakAlarmMinutes =
      GeneratedColumn<String>(
        'mid_break_alarm_minutes',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
        defaultValue: const Constant(''),
      );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    description,
    colorValue,
    isDefault,
    isActive,
    createdAt,
    alarmEnabled,
    expectedDurationMinutes,
    alarmSound,
    vibrationEnabled,
    alertStyle,
    reminderBehaviour,
    repeatIntervalMinutes,
    midBreakAlarmMinutes,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'break_types';
  @override
  VerificationContext validateIntegrity(
    Insertable<BreakType> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('description')) {
      context.handle(
        _descriptionMeta,
        description.isAcceptableOrUnknown(
          data['description']!,
          _descriptionMeta,
        ),
      );
    }
    if (data.containsKey('color_value')) {
      context.handle(
        _colorValueMeta,
        colorValue.isAcceptableOrUnknown(data['color_value']!, _colorValueMeta),
      );
    }
    if (data.containsKey('is_default')) {
      context.handle(
        _isDefaultMeta,
        isDefault.isAcceptableOrUnknown(data['is_default']!, _isDefaultMeta),
      );
    }
    if (data.containsKey('is_active')) {
      context.handle(
        _isActiveMeta,
        isActive.isAcceptableOrUnknown(data['is_active']!, _isActiveMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    if (data.containsKey('alarm_enabled')) {
      context.handle(
        _alarmEnabledMeta,
        alarmEnabled.isAcceptableOrUnknown(
          data['alarm_enabled']!,
          _alarmEnabledMeta,
        ),
      );
    }
    if (data.containsKey('expected_duration_minutes')) {
      context.handle(
        _expectedDurationMinutesMeta,
        expectedDurationMinutes.isAcceptableOrUnknown(
          data['expected_duration_minutes']!,
          _expectedDurationMinutesMeta,
        ),
      );
    }
    if (data.containsKey('vibration_enabled')) {
      context.handle(
        _vibrationEnabledMeta,
        vibrationEnabled.isAcceptableOrUnknown(
          data['vibration_enabled']!,
          _vibrationEnabledMeta,
        ),
      );
    }
    if (data.containsKey('repeat_interval_minutes')) {
      context.handle(
        _repeatIntervalMinutesMeta,
        repeatIntervalMinutes.isAcceptableOrUnknown(
          data['repeat_interval_minutes']!,
          _repeatIntervalMinutesMeta,
        ),
      );
    }
    if (data.containsKey('mid_break_alarm_minutes')) {
      context.handle(
        _midBreakAlarmMinutesMeta,
        midBreakAlarmMinutes.isAcceptableOrUnknown(
          data['mid_break_alarm_minutes']!,
          _midBreakAlarmMinutesMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  BreakType map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return BreakType(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      description: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}description'],
      ),
      colorValue: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}color_value'],
      ),
      isDefault: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_default'],
      )!,
      isActive: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_active'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      alarmEnabled: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}alarm_enabled'],
      )!,
      expectedDurationMinutes: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}expected_duration_minutes'],
      )!,
      alarmSound: $BreakTypesTable.$converteralarmSound.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}alarm_sound'],
        )!,
      ),
      vibrationEnabled: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}vibration_enabled'],
      )!,
      alertStyle: $BreakTypesTable.$converteralertStyle.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}alert_style'],
        )!,
      ),
      reminderBehaviour: $BreakTypesTable.$converterreminderBehaviour.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}reminder_behaviour'],
        )!,
      ),
      repeatIntervalMinutes: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}repeat_interval_minutes'],
      )!,
      midBreakAlarmMinutes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}mid_break_alarm_minutes'],
      )!,
    );
  }

  @override
  $BreakTypesTable createAlias(String alias) {
    return $BreakTypesTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<AlarmSound, String, String> $converteralarmSound =
      const EnumNameConverter<AlarmSound>(AlarmSound.values);
  static JsonTypeConverter2<AlarmAlertStyle, String, String>
  $converteralertStyle = const EnumNameConverter<AlarmAlertStyle>(
    AlarmAlertStyle.values,
  );
  static JsonTypeConverter2<ReminderBehaviour, String, String>
  $converterreminderBehaviour = const EnumNameConverter<ReminderBehaviour>(
    ReminderBehaviour.values,
  );
}

class BreakType extends DataClass implements Insertable<BreakType> {
  final int id;
  final String name;
  final String? description;
  final int? colorValue;
  final bool isDefault;
  final bool isActive;
  final DateTime createdAt;
  final bool alarmEnabled;
  final int expectedDurationMinutes;
  final AlarmSound alarmSound;
  final bool vibrationEnabled;
  final AlarmAlertStyle alertStyle;
  final ReminderBehaviour reminderBehaviour;
  final int repeatIntervalMinutes;
  final String midBreakAlarmMinutes;
  const BreakType({
    required this.id,
    required this.name,
    this.description,
    this.colorValue,
    required this.isDefault,
    required this.isActive,
    required this.createdAt,
    required this.alarmEnabled,
    required this.expectedDurationMinutes,
    required this.alarmSound,
    required this.vibrationEnabled,
    required this.alertStyle,
    required this.reminderBehaviour,
    required this.repeatIntervalMinutes,
    required this.midBreakAlarmMinutes,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || description != null) {
      map['description'] = Variable<String>(description);
    }
    if (!nullToAbsent || colorValue != null) {
      map['color_value'] = Variable<int>(colorValue);
    }
    map['is_default'] = Variable<bool>(isDefault);
    map['is_active'] = Variable<bool>(isActive);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['alarm_enabled'] = Variable<bool>(alarmEnabled);
    map['expected_duration_minutes'] = Variable<int>(expectedDurationMinutes);
    {
      map['alarm_sound'] = Variable<String>(
        $BreakTypesTable.$converteralarmSound.toSql(alarmSound),
      );
    }
    map['vibration_enabled'] = Variable<bool>(vibrationEnabled);
    {
      map['alert_style'] = Variable<String>(
        $BreakTypesTable.$converteralertStyle.toSql(alertStyle),
      );
    }
    {
      map['reminder_behaviour'] = Variable<String>(
        $BreakTypesTable.$converterreminderBehaviour.toSql(reminderBehaviour),
      );
    }
    map['repeat_interval_minutes'] = Variable<int>(repeatIntervalMinutes);
    map['mid_break_alarm_minutes'] = Variable<String>(midBreakAlarmMinutes);
    return map;
  }

  BreakTypesCompanion toCompanion(bool nullToAbsent) {
    return BreakTypesCompanion(
      id: Value(id),
      name: Value(name),
      description: description == null && nullToAbsent
          ? const Value.absent()
          : Value(description),
      colorValue: colorValue == null && nullToAbsent
          ? const Value.absent()
          : Value(colorValue),
      isDefault: Value(isDefault),
      isActive: Value(isActive),
      createdAt: Value(createdAt),
      alarmEnabled: Value(alarmEnabled),
      expectedDurationMinutes: Value(expectedDurationMinutes),
      alarmSound: Value(alarmSound),
      vibrationEnabled: Value(vibrationEnabled),
      alertStyle: Value(alertStyle),
      reminderBehaviour: Value(reminderBehaviour),
      repeatIntervalMinutes: Value(repeatIntervalMinutes),
      midBreakAlarmMinutes: Value(midBreakAlarmMinutes),
    );
  }

  factory BreakType.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return BreakType(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      description: serializer.fromJson<String?>(json['description']),
      colorValue: serializer.fromJson<int?>(json['colorValue']),
      isDefault: serializer.fromJson<bool>(json['isDefault']),
      isActive: serializer.fromJson<bool>(json['isActive']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      alarmEnabled: serializer.fromJson<bool>(json['alarmEnabled']),
      expectedDurationMinutes: serializer.fromJson<int>(
        json['expectedDurationMinutes'],
      ),
      alarmSound: $BreakTypesTable.$converteralarmSound.fromJson(
        serializer.fromJson<String>(json['alarmSound']),
      ),
      vibrationEnabled: serializer.fromJson<bool>(json['vibrationEnabled']),
      alertStyle: $BreakTypesTable.$converteralertStyle.fromJson(
        serializer.fromJson<String>(json['alertStyle']),
      ),
      reminderBehaviour: $BreakTypesTable.$converterreminderBehaviour.fromJson(
        serializer.fromJson<String>(json['reminderBehaviour']),
      ),
      repeatIntervalMinutes: serializer.fromJson<int>(
        json['repeatIntervalMinutes'],
      ),
      midBreakAlarmMinutes: serializer.fromJson<String>(
        json['midBreakAlarmMinutes'],
      ),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
      'description': serializer.toJson<String?>(description),
      'colorValue': serializer.toJson<int?>(colorValue),
      'isDefault': serializer.toJson<bool>(isDefault),
      'isActive': serializer.toJson<bool>(isActive),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'alarmEnabled': serializer.toJson<bool>(alarmEnabled),
      'expectedDurationMinutes': serializer.toJson<int>(
        expectedDurationMinutes,
      ),
      'alarmSound': serializer.toJson<String>(
        $BreakTypesTable.$converteralarmSound.toJson(alarmSound),
      ),
      'vibrationEnabled': serializer.toJson<bool>(vibrationEnabled),
      'alertStyle': serializer.toJson<String>(
        $BreakTypesTable.$converteralertStyle.toJson(alertStyle),
      ),
      'reminderBehaviour': serializer.toJson<String>(
        $BreakTypesTable.$converterreminderBehaviour.toJson(reminderBehaviour),
      ),
      'repeatIntervalMinutes': serializer.toJson<int>(repeatIntervalMinutes),
      'midBreakAlarmMinutes': serializer.toJson<String>(midBreakAlarmMinutes),
    };
  }

  BreakType copyWith({
    int? id,
    String? name,
    Value<String?> description = const Value.absent(),
    Value<int?> colorValue = const Value.absent(),
    bool? isDefault,
    bool? isActive,
    DateTime? createdAt,
    bool? alarmEnabled,
    int? expectedDurationMinutes,
    AlarmSound? alarmSound,
    bool? vibrationEnabled,
    AlarmAlertStyle? alertStyle,
    ReminderBehaviour? reminderBehaviour,
    int? repeatIntervalMinutes,
    String? midBreakAlarmMinutes,
  }) => BreakType(
    id: id ?? this.id,
    name: name ?? this.name,
    description: description.present ? description.value : this.description,
    colorValue: colorValue.present ? colorValue.value : this.colorValue,
    isDefault: isDefault ?? this.isDefault,
    isActive: isActive ?? this.isActive,
    createdAt: createdAt ?? this.createdAt,
    alarmEnabled: alarmEnabled ?? this.alarmEnabled,
    expectedDurationMinutes:
        expectedDurationMinutes ?? this.expectedDurationMinutes,
    alarmSound: alarmSound ?? this.alarmSound,
    vibrationEnabled: vibrationEnabled ?? this.vibrationEnabled,
    alertStyle: alertStyle ?? this.alertStyle,
    reminderBehaviour: reminderBehaviour ?? this.reminderBehaviour,
    repeatIntervalMinutes: repeatIntervalMinutes ?? this.repeatIntervalMinutes,
    midBreakAlarmMinutes: midBreakAlarmMinutes ?? this.midBreakAlarmMinutes,
  );
  BreakType copyWithCompanion(BreakTypesCompanion data) {
    return BreakType(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      description: data.description.present
          ? data.description.value
          : this.description,
      colorValue: data.colorValue.present
          ? data.colorValue.value
          : this.colorValue,
      isDefault: data.isDefault.present ? data.isDefault.value : this.isDefault,
      isActive: data.isActive.present ? data.isActive.value : this.isActive,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      alarmEnabled: data.alarmEnabled.present
          ? data.alarmEnabled.value
          : this.alarmEnabled,
      expectedDurationMinutes: data.expectedDurationMinutes.present
          ? data.expectedDurationMinutes.value
          : this.expectedDurationMinutes,
      alarmSound: data.alarmSound.present
          ? data.alarmSound.value
          : this.alarmSound,
      vibrationEnabled: data.vibrationEnabled.present
          ? data.vibrationEnabled.value
          : this.vibrationEnabled,
      alertStyle: data.alertStyle.present
          ? data.alertStyle.value
          : this.alertStyle,
      reminderBehaviour: data.reminderBehaviour.present
          ? data.reminderBehaviour.value
          : this.reminderBehaviour,
      repeatIntervalMinutes: data.repeatIntervalMinutes.present
          ? data.repeatIntervalMinutes.value
          : this.repeatIntervalMinutes,
      midBreakAlarmMinutes: data.midBreakAlarmMinutes.present
          ? data.midBreakAlarmMinutes.value
          : this.midBreakAlarmMinutes,
    );
  }

  @override
  String toString() {
    return (StringBuffer('BreakType(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('description: $description, ')
          ..write('colorValue: $colorValue, ')
          ..write('isDefault: $isDefault, ')
          ..write('isActive: $isActive, ')
          ..write('createdAt: $createdAt, ')
          ..write('alarmEnabled: $alarmEnabled, ')
          ..write('expectedDurationMinutes: $expectedDurationMinutes, ')
          ..write('alarmSound: $alarmSound, ')
          ..write('vibrationEnabled: $vibrationEnabled, ')
          ..write('alertStyle: $alertStyle, ')
          ..write('reminderBehaviour: $reminderBehaviour, ')
          ..write('repeatIntervalMinutes: $repeatIntervalMinutes, ')
          ..write('midBreakAlarmMinutes: $midBreakAlarmMinutes')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    name,
    description,
    colorValue,
    isDefault,
    isActive,
    createdAt,
    alarmEnabled,
    expectedDurationMinutes,
    alarmSound,
    vibrationEnabled,
    alertStyle,
    reminderBehaviour,
    repeatIntervalMinutes,
    midBreakAlarmMinutes,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is BreakType &&
          other.id == this.id &&
          other.name == this.name &&
          other.description == this.description &&
          other.colorValue == this.colorValue &&
          other.isDefault == this.isDefault &&
          other.isActive == this.isActive &&
          other.createdAt == this.createdAt &&
          other.alarmEnabled == this.alarmEnabled &&
          other.expectedDurationMinutes == this.expectedDurationMinutes &&
          other.alarmSound == this.alarmSound &&
          other.vibrationEnabled == this.vibrationEnabled &&
          other.alertStyle == this.alertStyle &&
          other.reminderBehaviour == this.reminderBehaviour &&
          other.repeatIntervalMinutes == this.repeatIntervalMinutes &&
          other.midBreakAlarmMinutes == this.midBreakAlarmMinutes);
}

class BreakTypesCompanion extends UpdateCompanion<BreakType> {
  final Value<int> id;
  final Value<String> name;
  final Value<String?> description;
  final Value<int?> colorValue;
  final Value<bool> isDefault;
  final Value<bool> isActive;
  final Value<DateTime> createdAt;
  final Value<bool> alarmEnabled;
  final Value<int> expectedDurationMinutes;
  final Value<AlarmSound> alarmSound;
  final Value<bool> vibrationEnabled;
  final Value<AlarmAlertStyle> alertStyle;
  final Value<ReminderBehaviour> reminderBehaviour;
  final Value<int> repeatIntervalMinutes;
  final Value<String> midBreakAlarmMinutes;
  const BreakTypesCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.description = const Value.absent(),
    this.colorValue = const Value.absent(),
    this.isDefault = const Value.absent(),
    this.isActive = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.alarmEnabled = const Value.absent(),
    this.expectedDurationMinutes = const Value.absent(),
    this.alarmSound = const Value.absent(),
    this.vibrationEnabled = const Value.absent(),
    this.alertStyle = const Value.absent(),
    this.reminderBehaviour = const Value.absent(),
    this.repeatIntervalMinutes = const Value.absent(),
    this.midBreakAlarmMinutes = const Value.absent(),
  });
  BreakTypesCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    this.description = const Value.absent(),
    this.colorValue = const Value.absent(),
    this.isDefault = const Value.absent(),
    this.isActive = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.alarmEnabled = const Value.absent(),
    this.expectedDurationMinutes = const Value.absent(),
    this.alarmSound = const Value.absent(),
    this.vibrationEnabled = const Value.absent(),
    this.alertStyle = const Value.absent(),
    this.reminderBehaviour = const Value.absent(),
    this.repeatIntervalMinutes = const Value.absent(),
    this.midBreakAlarmMinutes = const Value.absent(),
  }) : name = Value(name);
  static Insertable<BreakType> custom({
    Expression<int>? id,
    Expression<String>? name,
    Expression<String>? description,
    Expression<int>? colorValue,
    Expression<bool>? isDefault,
    Expression<bool>? isActive,
    Expression<DateTime>? createdAt,
    Expression<bool>? alarmEnabled,
    Expression<int>? expectedDurationMinutes,
    Expression<String>? alarmSound,
    Expression<bool>? vibrationEnabled,
    Expression<String>? alertStyle,
    Expression<String>? reminderBehaviour,
    Expression<int>? repeatIntervalMinutes,
    Expression<String>? midBreakAlarmMinutes,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (description != null) 'description': description,
      if (colorValue != null) 'color_value': colorValue,
      if (isDefault != null) 'is_default': isDefault,
      if (isActive != null) 'is_active': isActive,
      if (createdAt != null) 'created_at': createdAt,
      if (alarmEnabled != null) 'alarm_enabled': alarmEnabled,
      if (expectedDurationMinutes != null)
        'expected_duration_minutes': expectedDurationMinutes,
      if (alarmSound != null) 'alarm_sound': alarmSound,
      if (vibrationEnabled != null) 'vibration_enabled': vibrationEnabled,
      if (alertStyle != null) 'alert_style': alertStyle,
      if (reminderBehaviour != null) 'reminder_behaviour': reminderBehaviour,
      if (repeatIntervalMinutes != null)
        'repeat_interval_minutes': repeatIntervalMinutes,
      if (midBreakAlarmMinutes != null)
        'mid_break_alarm_minutes': midBreakAlarmMinutes,
    });
  }

  BreakTypesCompanion copyWith({
    Value<int>? id,
    Value<String>? name,
    Value<String?>? description,
    Value<int?>? colorValue,
    Value<bool>? isDefault,
    Value<bool>? isActive,
    Value<DateTime>? createdAt,
    Value<bool>? alarmEnabled,
    Value<int>? expectedDurationMinutes,
    Value<AlarmSound>? alarmSound,
    Value<bool>? vibrationEnabled,
    Value<AlarmAlertStyle>? alertStyle,
    Value<ReminderBehaviour>? reminderBehaviour,
    Value<int>? repeatIntervalMinutes,
    Value<String>? midBreakAlarmMinutes,
  }) {
    return BreakTypesCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      colorValue: colorValue ?? this.colorValue,
      isDefault: isDefault ?? this.isDefault,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      alarmEnabled: alarmEnabled ?? this.alarmEnabled,
      expectedDurationMinutes:
          expectedDurationMinutes ?? this.expectedDurationMinutes,
      alarmSound: alarmSound ?? this.alarmSound,
      vibrationEnabled: vibrationEnabled ?? this.vibrationEnabled,
      alertStyle: alertStyle ?? this.alertStyle,
      reminderBehaviour: reminderBehaviour ?? this.reminderBehaviour,
      repeatIntervalMinutes:
          repeatIntervalMinutes ?? this.repeatIntervalMinutes,
      midBreakAlarmMinutes: midBreakAlarmMinutes ?? this.midBreakAlarmMinutes,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (colorValue.present) {
      map['color_value'] = Variable<int>(colorValue.value);
    }
    if (isDefault.present) {
      map['is_default'] = Variable<bool>(isDefault.value);
    }
    if (isActive.present) {
      map['is_active'] = Variable<bool>(isActive.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (alarmEnabled.present) {
      map['alarm_enabled'] = Variable<bool>(alarmEnabled.value);
    }
    if (expectedDurationMinutes.present) {
      map['expected_duration_minutes'] = Variable<int>(
        expectedDurationMinutes.value,
      );
    }
    if (alarmSound.present) {
      map['alarm_sound'] = Variable<String>(
        $BreakTypesTable.$converteralarmSound.toSql(alarmSound.value),
      );
    }
    if (vibrationEnabled.present) {
      map['vibration_enabled'] = Variable<bool>(vibrationEnabled.value);
    }
    if (alertStyle.present) {
      map['alert_style'] = Variable<String>(
        $BreakTypesTable.$converteralertStyle.toSql(alertStyle.value),
      );
    }
    if (reminderBehaviour.present) {
      map['reminder_behaviour'] = Variable<String>(
        $BreakTypesTable.$converterreminderBehaviour.toSql(
          reminderBehaviour.value,
        ),
      );
    }
    if (repeatIntervalMinutes.present) {
      map['repeat_interval_minutes'] = Variable<int>(
        repeatIntervalMinutes.value,
      );
    }
    if (midBreakAlarmMinutes.present) {
      map['mid_break_alarm_minutes'] = Variable<String>(
        midBreakAlarmMinutes.value,
      );
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('BreakTypesCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('description: $description, ')
          ..write('colorValue: $colorValue, ')
          ..write('isDefault: $isDefault, ')
          ..write('isActive: $isActive, ')
          ..write('createdAt: $createdAt, ')
          ..write('alarmEnabled: $alarmEnabled, ')
          ..write('expectedDurationMinutes: $expectedDurationMinutes, ')
          ..write('alarmSound: $alarmSound, ')
          ..write('vibrationEnabled: $vibrationEnabled, ')
          ..write('alertStyle: $alertStyle, ')
          ..write('reminderBehaviour: $reminderBehaviour, ')
          ..write('repeatIntervalMinutes: $repeatIntervalMinutes, ')
          ..write('midBreakAlarmMinutes: $midBreakAlarmMinutes')
          ..write(')'))
        .toString();
  }
}

class $ActivitiesTable extends Activities
    with TableInfo<$ActivitiesTable, Activity> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ActivitiesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  @override
  late final GeneratedColumnWithTypeConverter<ActivityKind, String> kind =
      GeneratedColumn<String>(
        'kind',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<ActivityKind>($ActivitiesTable.$converterkind);
  static const VerificationMeta _breakTypeIdMeta = const VerificationMeta(
    'breakTypeId',
  );
  @override
  late final GeneratedColumn<int> breakTypeId = GeneratedColumn<int>(
    'break_type_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES break_types (id)',
    ),
  );
  static const VerificationMeta _startTimeMeta = const VerificationMeta(
    'startTime',
  );
  @override
  late final GeneratedColumn<DateTime> startTime = GeneratedColumn<DateTime>(
    'start_time',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _endTimeMeta = const VerificationMeta(
    'endTime',
  );
  @override
  late final GeneratedColumn<DateTime> endTime = GeneratedColumn<DateTime>(
    'end_time',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _durationSecondsMeta = const VerificationMeta(
    'durationSeconds',
  );
  @override
  late final GeneratedColumn<int> durationSeconds = GeneratedColumn<int>(
    'duration_seconds',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _dayKeyMeta = const VerificationMeta('dayKey');
  @override
  late final GeneratedColumn<String> dayKey = GeneratedColumn<String>(
    'day_key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _targetMinutesMeta = const VerificationMeta(
    'targetMinutes',
  );
  @override
  late final GeneratedColumn<int> targetMinutes = GeneratedColumn<int>(
    'target_minutes',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    kind,
    breakTypeId,
    startTime,
    endTime,
    durationSeconds,
    dayKey,
    targetMinutes,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'activities';
  @override
  VerificationContext validateIntegrity(
    Insertable<Activity> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('break_type_id')) {
      context.handle(
        _breakTypeIdMeta,
        breakTypeId.isAcceptableOrUnknown(
          data['break_type_id']!,
          _breakTypeIdMeta,
        ),
      );
    }
    if (data.containsKey('start_time')) {
      context.handle(
        _startTimeMeta,
        startTime.isAcceptableOrUnknown(data['start_time']!, _startTimeMeta),
      );
    } else if (isInserting) {
      context.missing(_startTimeMeta);
    }
    if (data.containsKey('end_time')) {
      context.handle(
        _endTimeMeta,
        endTime.isAcceptableOrUnknown(data['end_time']!, _endTimeMeta),
      );
    }
    if (data.containsKey('duration_seconds')) {
      context.handle(
        _durationSecondsMeta,
        durationSeconds.isAcceptableOrUnknown(
          data['duration_seconds']!,
          _durationSecondsMeta,
        ),
      );
    }
    if (data.containsKey('day_key')) {
      context.handle(
        _dayKeyMeta,
        dayKey.isAcceptableOrUnknown(data['day_key']!, _dayKeyMeta),
      );
    } else if (isInserting) {
      context.missing(_dayKeyMeta);
    }
    if (data.containsKey('target_minutes')) {
      context.handle(
        _targetMinutesMeta,
        targetMinutes.isAcceptableOrUnknown(
          data['target_minutes']!,
          _targetMinutesMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Activity map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Activity(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      kind: $ActivitiesTable.$converterkind.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}kind'],
        )!,
      ),
      breakTypeId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}break_type_id'],
      ),
      startTime: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}start_time'],
      )!,
      endTime: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}end_time'],
      ),
      durationSeconds: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}duration_seconds'],
      ),
      dayKey: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}day_key'],
      )!,
      targetMinutes: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}target_minutes'],
      ),
    );
  }

  @override
  $ActivitiesTable createAlias(String alias) {
    return $ActivitiesTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<ActivityKind, String, String> $converterkind =
      const EnumNameConverter<ActivityKind>(ActivityKind.values);
}

class Activity extends DataClass implements Insertable<Activity> {
  final int id;
  final ActivityKind kind;
  final int? breakTypeId;
  final DateTime startTime;
  final DateTime? endTime;
  final int? durationSeconds;
  final String dayKey;
  final int? targetMinutes;
  const Activity({
    required this.id,
    required this.kind,
    this.breakTypeId,
    required this.startTime,
    this.endTime,
    this.durationSeconds,
    required this.dayKey,
    this.targetMinutes,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    {
      map['kind'] = Variable<String>(
        $ActivitiesTable.$converterkind.toSql(kind),
      );
    }
    if (!nullToAbsent || breakTypeId != null) {
      map['break_type_id'] = Variable<int>(breakTypeId);
    }
    map['start_time'] = Variable<DateTime>(startTime);
    if (!nullToAbsent || endTime != null) {
      map['end_time'] = Variable<DateTime>(endTime);
    }
    if (!nullToAbsent || durationSeconds != null) {
      map['duration_seconds'] = Variable<int>(durationSeconds);
    }
    map['day_key'] = Variable<String>(dayKey);
    if (!nullToAbsent || targetMinutes != null) {
      map['target_minutes'] = Variable<int>(targetMinutes);
    }
    return map;
  }

  ActivitiesCompanion toCompanion(bool nullToAbsent) {
    return ActivitiesCompanion(
      id: Value(id),
      kind: Value(kind),
      breakTypeId: breakTypeId == null && nullToAbsent
          ? const Value.absent()
          : Value(breakTypeId),
      startTime: Value(startTime),
      endTime: endTime == null && nullToAbsent
          ? const Value.absent()
          : Value(endTime),
      durationSeconds: durationSeconds == null && nullToAbsent
          ? const Value.absent()
          : Value(durationSeconds),
      dayKey: Value(dayKey),
      targetMinutes: targetMinutes == null && nullToAbsent
          ? const Value.absent()
          : Value(targetMinutes),
    );
  }

  factory Activity.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Activity(
      id: serializer.fromJson<int>(json['id']),
      kind: $ActivitiesTable.$converterkind.fromJson(
        serializer.fromJson<String>(json['kind']),
      ),
      breakTypeId: serializer.fromJson<int?>(json['breakTypeId']),
      startTime: serializer.fromJson<DateTime>(json['startTime']),
      endTime: serializer.fromJson<DateTime?>(json['endTime']),
      durationSeconds: serializer.fromJson<int?>(json['durationSeconds']),
      dayKey: serializer.fromJson<String>(json['dayKey']),
      targetMinutes: serializer.fromJson<int?>(json['targetMinutes']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'kind': serializer.toJson<String>(
        $ActivitiesTable.$converterkind.toJson(kind),
      ),
      'breakTypeId': serializer.toJson<int?>(breakTypeId),
      'startTime': serializer.toJson<DateTime>(startTime),
      'endTime': serializer.toJson<DateTime?>(endTime),
      'durationSeconds': serializer.toJson<int?>(durationSeconds),
      'dayKey': serializer.toJson<String>(dayKey),
      'targetMinutes': serializer.toJson<int?>(targetMinutes),
    };
  }

  Activity copyWith({
    int? id,
    ActivityKind? kind,
    Value<int?> breakTypeId = const Value.absent(),
    DateTime? startTime,
    Value<DateTime?> endTime = const Value.absent(),
    Value<int?> durationSeconds = const Value.absent(),
    String? dayKey,
    Value<int?> targetMinutes = const Value.absent(),
  }) => Activity(
    id: id ?? this.id,
    kind: kind ?? this.kind,
    breakTypeId: breakTypeId.present ? breakTypeId.value : this.breakTypeId,
    startTime: startTime ?? this.startTime,
    endTime: endTime.present ? endTime.value : this.endTime,
    durationSeconds: durationSeconds.present
        ? durationSeconds.value
        : this.durationSeconds,
    dayKey: dayKey ?? this.dayKey,
    targetMinutes: targetMinutes.present
        ? targetMinutes.value
        : this.targetMinutes,
  );
  Activity copyWithCompanion(ActivitiesCompanion data) {
    return Activity(
      id: data.id.present ? data.id.value : this.id,
      kind: data.kind.present ? data.kind.value : this.kind,
      breakTypeId: data.breakTypeId.present
          ? data.breakTypeId.value
          : this.breakTypeId,
      startTime: data.startTime.present ? data.startTime.value : this.startTime,
      endTime: data.endTime.present ? data.endTime.value : this.endTime,
      durationSeconds: data.durationSeconds.present
          ? data.durationSeconds.value
          : this.durationSeconds,
      dayKey: data.dayKey.present ? data.dayKey.value : this.dayKey,
      targetMinutes: data.targetMinutes.present
          ? data.targetMinutes.value
          : this.targetMinutes,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Activity(')
          ..write('id: $id, ')
          ..write('kind: $kind, ')
          ..write('breakTypeId: $breakTypeId, ')
          ..write('startTime: $startTime, ')
          ..write('endTime: $endTime, ')
          ..write('durationSeconds: $durationSeconds, ')
          ..write('dayKey: $dayKey, ')
          ..write('targetMinutes: $targetMinutes')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    kind,
    breakTypeId,
    startTime,
    endTime,
    durationSeconds,
    dayKey,
    targetMinutes,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Activity &&
          other.id == this.id &&
          other.kind == this.kind &&
          other.breakTypeId == this.breakTypeId &&
          other.startTime == this.startTime &&
          other.endTime == this.endTime &&
          other.durationSeconds == this.durationSeconds &&
          other.dayKey == this.dayKey &&
          other.targetMinutes == this.targetMinutes);
}

class ActivitiesCompanion extends UpdateCompanion<Activity> {
  final Value<int> id;
  final Value<ActivityKind> kind;
  final Value<int?> breakTypeId;
  final Value<DateTime> startTime;
  final Value<DateTime?> endTime;
  final Value<int?> durationSeconds;
  final Value<String> dayKey;
  final Value<int?> targetMinutes;
  const ActivitiesCompanion({
    this.id = const Value.absent(),
    this.kind = const Value.absent(),
    this.breakTypeId = const Value.absent(),
    this.startTime = const Value.absent(),
    this.endTime = const Value.absent(),
    this.durationSeconds = const Value.absent(),
    this.dayKey = const Value.absent(),
    this.targetMinutes = const Value.absent(),
  });
  ActivitiesCompanion.insert({
    this.id = const Value.absent(),
    required ActivityKind kind,
    this.breakTypeId = const Value.absent(),
    required DateTime startTime,
    this.endTime = const Value.absent(),
    this.durationSeconds = const Value.absent(),
    required String dayKey,
    this.targetMinutes = const Value.absent(),
  }) : kind = Value(kind),
       startTime = Value(startTime),
       dayKey = Value(dayKey);
  static Insertable<Activity> custom({
    Expression<int>? id,
    Expression<String>? kind,
    Expression<int>? breakTypeId,
    Expression<DateTime>? startTime,
    Expression<DateTime>? endTime,
    Expression<int>? durationSeconds,
    Expression<String>? dayKey,
    Expression<int>? targetMinutes,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (kind != null) 'kind': kind,
      if (breakTypeId != null) 'break_type_id': breakTypeId,
      if (startTime != null) 'start_time': startTime,
      if (endTime != null) 'end_time': endTime,
      if (durationSeconds != null) 'duration_seconds': durationSeconds,
      if (dayKey != null) 'day_key': dayKey,
      if (targetMinutes != null) 'target_minutes': targetMinutes,
    });
  }

  ActivitiesCompanion copyWith({
    Value<int>? id,
    Value<ActivityKind>? kind,
    Value<int?>? breakTypeId,
    Value<DateTime>? startTime,
    Value<DateTime?>? endTime,
    Value<int?>? durationSeconds,
    Value<String>? dayKey,
    Value<int?>? targetMinutes,
  }) {
    return ActivitiesCompanion(
      id: id ?? this.id,
      kind: kind ?? this.kind,
      breakTypeId: breakTypeId ?? this.breakTypeId,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      durationSeconds: durationSeconds ?? this.durationSeconds,
      dayKey: dayKey ?? this.dayKey,
      targetMinutes: targetMinutes ?? this.targetMinutes,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (kind.present) {
      map['kind'] = Variable<String>(
        $ActivitiesTable.$converterkind.toSql(kind.value),
      );
    }
    if (breakTypeId.present) {
      map['break_type_id'] = Variable<int>(breakTypeId.value);
    }
    if (startTime.present) {
      map['start_time'] = Variable<DateTime>(startTime.value);
    }
    if (endTime.present) {
      map['end_time'] = Variable<DateTime>(endTime.value);
    }
    if (durationSeconds.present) {
      map['duration_seconds'] = Variable<int>(durationSeconds.value);
    }
    if (dayKey.present) {
      map['day_key'] = Variable<String>(dayKey.value);
    }
    if (targetMinutes.present) {
      map['target_minutes'] = Variable<int>(targetMinutes.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ActivitiesCompanion(')
          ..write('id: $id, ')
          ..write('kind: $kind, ')
          ..write('breakTypeId: $breakTypeId, ')
          ..write('startTime: $startTime, ')
          ..write('endTime: $endTime, ')
          ..write('durationSeconds: $durationSeconds, ')
          ..write('dayKey: $dayKey, ')
          ..write('targetMinutes: $targetMinutes')
          ..write(')'))
        .toString();
  }
}

class $AppSettingsTable extends AppSettings
    with TableInfo<$AppSettingsTable, AppSetting> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AppSettingsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _dailyTargetMinutesMeta =
      const VerificationMeta('dailyTargetMinutes');
  @override
  late final GeneratedColumn<int> dailyTargetMinutes = GeneratedColumn<int>(
    'daily_target_minutes',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(480),
  );
  static const VerificationMeta _allowedBreakMinutesMeta =
      const VerificationMeta('allowedBreakMinutes');
  @override
  late final GeneratedColumn<int> allowedBreakMinutes = GeneratedColumn<int>(
    'allowed_break_minutes',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(60),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    dailyTargetMinutes,
    allowedBreakMinutes,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'app_settings';
  @override
  VerificationContext validateIntegrity(
    Insertable<AppSetting> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('daily_target_minutes')) {
      context.handle(
        _dailyTargetMinutesMeta,
        dailyTargetMinutes.isAcceptableOrUnknown(
          data['daily_target_minutes']!,
          _dailyTargetMinutesMeta,
        ),
      );
    }
    if (data.containsKey('allowed_break_minutes')) {
      context.handle(
        _allowedBreakMinutesMeta,
        allowedBreakMinutes.isAcceptableOrUnknown(
          data['allowed_break_minutes']!,
          _allowedBreakMinutesMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  AppSetting map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AppSetting(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      dailyTargetMinutes: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}daily_target_minutes'],
      )!,
      allowedBreakMinutes: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}allowed_break_minutes'],
      )!,
    );
  }

  @override
  $AppSettingsTable createAlias(String alias) {
    return $AppSettingsTable(attachedDatabase, alias);
  }
}

class AppSetting extends DataClass implements Insertable<AppSetting> {
  final int id;
  final int dailyTargetMinutes;
  final int allowedBreakMinutes;
  const AppSetting({
    required this.id,
    required this.dailyTargetMinutes,
    required this.allowedBreakMinutes,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['daily_target_minutes'] = Variable<int>(dailyTargetMinutes);
    map['allowed_break_minutes'] = Variable<int>(allowedBreakMinutes);
    return map;
  }

  AppSettingsCompanion toCompanion(bool nullToAbsent) {
    return AppSettingsCompanion(
      id: Value(id),
      dailyTargetMinutes: Value(dailyTargetMinutes),
      allowedBreakMinutes: Value(allowedBreakMinutes),
    );
  }

  factory AppSetting.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AppSetting(
      id: serializer.fromJson<int>(json['id']),
      dailyTargetMinutes: serializer.fromJson<int>(json['dailyTargetMinutes']),
      allowedBreakMinutes: serializer.fromJson<int>(
        json['allowedBreakMinutes'],
      ),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'dailyTargetMinutes': serializer.toJson<int>(dailyTargetMinutes),
      'allowedBreakMinutes': serializer.toJson<int>(allowedBreakMinutes),
    };
  }

  AppSetting copyWith({
    int? id,
    int? dailyTargetMinutes,
    int? allowedBreakMinutes,
  }) => AppSetting(
    id: id ?? this.id,
    dailyTargetMinutes: dailyTargetMinutes ?? this.dailyTargetMinutes,
    allowedBreakMinutes: allowedBreakMinutes ?? this.allowedBreakMinutes,
  );
  AppSetting copyWithCompanion(AppSettingsCompanion data) {
    return AppSetting(
      id: data.id.present ? data.id.value : this.id,
      dailyTargetMinutes: data.dailyTargetMinutes.present
          ? data.dailyTargetMinutes.value
          : this.dailyTargetMinutes,
      allowedBreakMinutes: data.allowedBreakMinutes.present
          ? data.allowedBreakMinutes.value
          : this.allowedBreakMinutes,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AppSetting(')
          ..write('id: $id, ')
          ..write('dailyTargetMinutes: $dailyTargetMinutes, ')
          ..write('allowedBreakMinutes: $allowedBreakMinutes')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, dailyTargetMinutes, allowedBreakMinutes);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AppSetting &&
          other.id == this.id &&
          other.dailyTargetMinutes == this.dailyTargetMinutes &&
          other.allowedBreakMinutes == this.allowedBreakMinutes);
}

class AppSettingsCompanion extends UpdateCompanion<AppSetting> {
  final Value<int> id;
  final Value<int> dailyTargetMinutes;
  final Value<int> allowedBreakMinutes;
  const AppSettingsCompanion({
    this.id = const Value.absent(),
    this.dailyTargetMinutes = const Value.absent(),
    this.allowedBreakMinutes = const Value.absent(),
  });
  AppSettingsCompanion.insert({
    this.id = const Value.absent(),
    this.dailyTargetMinutes = const Value.absent(),
    this.allowedBreakMinutes = const Value.absent(),
  });
  static Insertable<AppSetting> custom({
    Expression<int>? id,
    Expression<int>? dailyTargetMinutes,
    Expression<int>? allowedBreakMinutes,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (dailyTargetMinutes != null)
        'daily_target_minutes': dailyTargetMinutes,
      if (allowedBreakMinutes != null)
        'allowed_break_minutes': allowedBreakMinutes,
    });
  }

  AppSettingsCompanion copyWith({
    Value<int>? id,
    Value<int>? dailyTargetMinutes,
    Value<int>? allowedBreakMinutes,
  }) {
    return AppSettingsCompanion(
      id: id ?? this.id,
      dailyTargetMinutes: dailyTargetMinutes ?? this.dailyTargetMinutes,
      allowedBreakMinutes: allowedBreakMinutes ?? this.allowedBreakMinutes,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (dailyTargetMinutes.present) {
      map['daily_target_minutes'] = Variable<int>(dailyTargetMinutes.value);
    }
    if (allowedBreakMinutes.present) {
      map['allowed_break_minutes'] = Variable<int>(allowedBreakMinutes.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AppSettingsCompanion(')
          ..write('id: $id, ')
          ..write('dailyTargetMinutes: $dailyTargetMinutes, ')
          ..write('allowedBreakMinutes: $allowedBreakMinutes')
          ..write(')'))
        .toString();
  }
}

class $TasksTable extends Tasks with TableInfo<$TasksTable, Task> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TasksTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 120,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
    'notes',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _dueAtMeta = const VerificationMeta('dueAt');
  @override
  late final GeneratedColumn<DateTime> dueAt = GeneratedColumn<DateTime>(
    'due_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _locationNameMeta = const VerificationMeta(
    'locationName',
  );
  @override
  late final GeneratedColumn<String> locationName = GeneratedColumn<String>(
    'location_name',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _latitudeMeta = const VerificationMeta(
    'latitude',
  );
  @override
  late final GeneratedColumn<double> latitude = GeneratedColumn<double>(
    'latitude',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _longitudeMeta = const VerificationMeta(
    'longitude',
  );
  @override
  late final GeneratedColumn<double> longitude = GeneratedColumn<double>(
    'longitude',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _radiusMetersMeta = const VerificationMeta(
    'radiusMeters',
  );
  @override
  late final GeneratedColumn<int> radiusMeters = GeneratedColumn<int>(
    'radius_meters',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _isDoneMeta = const VerificationMeta('isDone');
  @override
  late final GeneratedColumn<bool> isDone = GeneratedColumn<bool>(
    'is_done',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_done" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    title,
    notes,
    dueAt,
    locationName,
    latitude,
    longitude,
    radiusMeters,
    isDone,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'tasks';
  @override
  VerificationContext validateIntegrity(
    Insertable<Task> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('notes')) {
      context.handle(
        _notesMeta,
        notes.isAcceptableOrUnknown(data['notes']!, _notesMeta),
      );
    }
    if (data.containsKey('due_at')) {
      context.handle(
        _dueAtMeta,
        dueAt.isAcceptableOrUnknown(data['due_at']!, _dueAtMeta),
      );
    }
    if (data.containsKey('location_name')) {
      context.handle(
        _locationNameMeta,
        locationName.isAcceptableOrUnknown(
          data['location_name']!,
          _locationNameMeta,
        ),
      );
    }
    if (data.containsKey('latitude')) {
      context.handle(
        _latitudeMeta,
        latitude.isAcceptableOrUnknown(data['latitude']!, _latitudeMeta),
      );
    }
    if (data.containsKey('longitude')) {
      context.handle(
        _longitudeMeta,
        longitude.isAcceptableOrUnknown(data['longitude']!, _longitudeMeta),
      );
    }
    if (data.containsKey('radius_meters')) {
      context.handle(
        _radiusMetersMeta,
        radiusMeters.isAcceptableOrUnknown(
          data['radius_meters']!,
          _radiusMetersMeta,
        ),
      );
    }
    if (data.containsKey('is_done')) {
      context.handle(
        _isDoneMeta,
        isDone.isAcceptableOrUnknown(data['is_done']!, _isDoneMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Task map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Task(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      notes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}notes'],
      ),
      dueAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}due_at'],
      ),
      locationName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}location_name'],
      ),
      latitude: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}latitude'],
      ),
      longitude: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}longitude'],
      ),
      radiusMeters: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}radius_meters'],
      ),
      isDone: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_done'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $TasksTable createAlias(String alias) {
    return $TasksTable(attachedDatabase, alias);
  }
}

class Task extends DataClass implements Insertable<Task> {
  final int id;
  final String title;
  final String? notes;
  final DateTime? dueAt;
  final String? locationName;
  final double? latitude;
  final double? longitude;
  final int? radiusMeters;
  final bool isDone;
  final DateTime createdAt;
  const Task({
    required this.id,
    required this.title,
    this.notes,
    this.dueAt,
    this.locationName,
    this.latitude,
    this.longitude,
    this.radiusMeters,
    required this.isDone,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['title'] = Variable<String>(title);
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    if (!nullToAbsent || dueAt != null) {
      map['due_at'] = Variable<DateTime>(dueAt);
    }
    if (!nullToAbsent || locationName != null) {
      map['location_name'] = Variable<String>(locationName);
    }
    if (!nullToAbsent || latitude != null) {
      map['latitude'] = Variable<double>(latitude);
    }
    if (!nullToAbsent || longitude != null) {
      map['longitude'] = Variable<double>(longitude);
    }
    if (!nullToAbsent || radiusMeters != null) {
      map['radius_meters'] = Variable<int>(radiusMeters);
    }
    map['is_done'] = Variable<bool>(isDone);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  TasksCompanion toCompanion(bool nullToAbsent) {
    return TasksCompanion(
      id: Value(id),
      title: Value(title),
      notes: notes == null && nullToAbsent
          ? const Value.absent()
          : Value(notes),
      dueAt: dueAt == null && nullToAbsent
          ? const Value.absent()
          : Value(dueAt),
      locationName: locationName == null && nullToAbsent
          ? const Value.absent()
          : Value(locationName),
      latitude: latitude == null && nullToAbsent
          ? const Value.absent()
          : Value(latitude),
      longitude: longitude == null && nullToAbsent
          ? const Value.absent()
          : Value(longitude),
      radiusMeters: radiusMeters == null && nullToAbsent
          ? const Value.absent()
          : Value(radiusMeters),
      isDone: Value(isDone),
      createdAt: Value(createdAt),
    );
  }

  factory Task.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Task(
      id: serializer.fromJson<int>(json['id']),
      title: serializer.fromJson<String>(json['title']),
      notes: serializer.fromJson<String?>(json['notes']),
      dueAt: serializer.fromJson<DateTime?>(json['dueAt']),
      locationName: serializer.fromJson<String?>(json['locationName']),
      latitude: serializer.fromJson<double?>(json['latitude']),
      longitude: serializer.fromJson<double?>(json['longitude']),
      radiusMeters: serializer.fromJson<int?>(json['radiusMeters']),
      isDone: serializer.fromJson<bool>(json['isDone']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'title': serializer.toJson<String>(title),
      'notes': serializer.toJson<String?>(notes),
      'dueAt': serializer.toJson<DateTime?>(dueAt),
      'locationName': serializer.toJson<String?>(locationName),
      'latitude': serializer.toJson<double?>(latitude),
      'longitude': serializer.toJson<double?>(longitude),
      'radiusMeters': serializer.toJson<int?>(radiusMeters),
      'isDone': serializer.toJson<bool>(isDone),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  Task copyWith({
    int? id,
    String? title,
    Value<String?> notes = const Value.absent(),
    Value<DateTime?> dueAt = const Value.absent(),
    Value<String?> locationName = const Value.absent(),
    Value<double?> latitude = const Value.absent(),
    Value<double?> longitude = const Value.absent(),
    Value<int?> radiusMeters = const Value.absent(),
    bool? isDone,
    DateTime? createdAt,
  }) => Task(
    id: id ?? this.id,
    title: title ?? this.title,
    notes: notes.present ? notes.value : this.notes,
    dueAt: dueAt.present ? dueAt.value : this.dueAt,
    locationName: locationName.present ? locationName.value : this.locationName,
    latitude: latitude.present ? latitude.value : this.latitude,
    longitude: longitude.present ? longitude.value : this.longitude,
    radiusMeters: radiusMeters.present ? radiusMeters.value : this.radiusMeters,
    isDone: isDone ?? this.isDone,
    createdAt: createdAt ?? this.createdAt,
  );
  Task copyWithCompanion(TasksCompanion data) {
    return Task(
      id: data.id.present ? data.id.value : this.id,
      title: data.title.present ? data.title.value : this.title,
      notes: data.notes.present ? data.notes.value : this.notes,
      dueAt: data.dueAt.present ? data.dueAt.value : this.dueAt,
      locationName: data.locationName.present
          ? data.locationName.value
          : this.locationName,
      latitude: data.latitude.present ? data.latitude.value : this.latitude,
      longitude: data.longitude.present ? data.longitude.value : this.longitude,
      radiusMeters: data.radiusMeters.present
          ? data.radiusMeters.value
          : this.radiusMeters,
      isDone: data.isDone.present ? data.isDone.value : this.isDone,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Task(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('notes: $notes, ')
          ..write('dueAt: $dueAt, ')
          ..write('locationName: $locationName, ')
          ..write('latitude: $latitude, ')
          ..write('longitude: $longitude, ')
          ..write('radiusMeters: $radiusMeters, ')
          ..write('isDone: $isDone, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    title,
    notes,
    dueAt,
    locationName,
    latitude,
    longitude,
    radiusMeters,
    isDone,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Task &&
          other.id == this.id &&
          other.title == this.title &&
          other.notes == this.notes &&
          other.dueAt == this.dueAt &&
          other.locationName == this.locationName &&
          other.latitude == this.latitude &&
          other.longitude == this.longitude &&
          other.radiusMeters == this.radiusMeters &&
          other.isDone == this.isDone &&
          other.createdAt == this.createdAt);
}

class TasksCompanion extends UpdateCompanion<Task> {
  final Value<int> id;
  final Value<String> title;
  final Value<String?> notes;
  final Value<DateTime?> dueAt;
  final Value<String?> locationName;
  final Value<double?> latitude;
  final Value<double?> longitude;
  final Value<int?> radiusMeters;
  final Value<bool> isDone;
  final Value<DateTime> createdAt;
  const TasksCompanion({
    this.id = const Value.absent(),
    this.title = const Value.absent(),
    this.notes = const Value.absent(),
    this.dueAt = const Value.absent(),
    this.locationName = const Value.absent(),
    this.latitude = const Value.absent(),
    this.longitude = const Value.absent(),
    this.radiusMeters = const Value.absent(),
    this.isDone = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  TasksCompanion.insert({
    this.id = const Value.absent(),
    required String title,
    this.notes = const Value.absent(),
    this.dueAt = const Value.absent(),
    this.locationName = const Value.absent(),
    this.latitude = const Value.absent(),
    this.longitude = const Value.absent(),
    this.radiusMeters = const Value.absent(),
    this.isDone = const Value.absent(),
    this.createdAt = const Value.absent(),
  }) : title = Value(title);
  static Insertable<Task> custom({
    Expression<int>? id,
    Expression<String>? title,
    Expression<String>? notes,
    Expression<DateTime>? dueAt,
    Expression<String>? locationName,
    Expression<double>? latitude,
    Expression<double>? longitude,
    Expression<int>? radiusMeters,
    Expression<bool>? isDone,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (title != null) 'title': title,
      if (notes != null) 'notes': notes,
      if (dueAt != null) 'due_at': dueAt,
      if (locationName != null) 'location_name': locationName,
      if (latitude != null) 'latitude': latitude,
      if (longitude != null) 'longitude': longitude,
      if (radiusMeters != null) 'radius_meters': radiusMeters,
      if (isDone != null) 'is_done': isDone,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  TasksCompanion copyWith({
    Value<int>? id,
    Value<String>? title,
    Value<String?>? notes,
    Value<DateTime?>? dueAt,
    Value<String?>? locationName,
    Value<double?>? latitude,
    Value<double?>? longitude,
    Value<int?>? radiusMeters,
    Value<bool>? isDone,
    Value<DateTime>? createdAt,
  }) {
    return TasksCompanion(
      id: id ?? this.id,
      title: title ?? this.title,
      notes: notes ?? this.notes,
      dueAt: dueAt ?? this.dueAt,
      locationName: locationName ?? this.locationName,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      radiusMeters: radiusMeters ?? this.radiusMeters,
      isDone: isDone ?? this.isDone,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (dueAt.present) {
      map['due_at'] = Variable<DateTime>(dueAt.value);
    }
    if (locationName.present) {
      map['location_name'] = Variable<String>(locationName.value);
    }
    if (latitude.present) {
      map['latitude'] = Variable<double>(latitude.value);
    }
    if (longitude.present) {
      map['longitude'] = Variable<double>(longitude.value);
    }
    if (radiusMeters.present) {
      map['radius_meters'] = Variable<int>(radiusMeters.value);
    }
    if (isDone.present) {
      map['is_done'] = Variable<bool>(isDone.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TasksCompanion(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('notes: $notes, ')
          ..write('dueAt: $dueAt, ')
          ..write('locationName: $locationName, ')
          ..write('latitude: $latitude, ')
          ..write('longitude: $longitude, ')
          ..write('radiusMeters: $radiusMeters, ')
          ..write('isDone: $isDone, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $BreakTypesTable breakTypes = $BreakTypesTable(this);
  late final $ActivitiesTable activities = $ActivitiesTable(this);
  late final $AppSettingsTable appSettings = $AppSettingsTable(this);
  late final $TasksTable tasks = $TasksTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    breakTypes,
    activities,
    appSettings,
    tasks,
  ];
}

typedef $$BreakTypesTableCreateCompanionBuilder = BreakTypesCompanion Function({
  Value<int> id,
  required String name,
  Value<String?> description,
  Value<int?> colorValue,
  Value<bool> isDefault,
  Value<bool> isActive,
  Value<DateTime> createdAt,
  Value<bool> alarmEnabled,
  Value<int> expectedDurationMinutes,
  Value<AlarmSound> alarmSound,
  Value<bool> vibrationEnabled,
  Value<AlarmAlertStyle> alertStyle,
  Value<ReminderBehaviour> reminderBehaviour,
  Value<int> repeatIntervalMinutes,
  Value<String> midBreakAlarmMinutes,
});
typedef $$BreakTypesTableUpdateCompanionBuilder = BreakTypesCompanion Function({
  Value<int> id,
  Value<String> name,
  Value<String?> description,
  Value<int?> colorValue,
  Value<bool> isDefault,
  Value<bool> isActive,
  Value<DateTime> createdAt,
  Value<bool> alarmEnabled,
  Value<int> expectedDurationMinutes,
  Value<AlarmSound> alarmSound,
  Value<bool> vibrationEnabled,
  Value<AlarmAlertStyle> alertStyle,
  Value<ReminderBehaviour> reminderBehaviour,
  Value<int> repeatIntervalMinutes,
  Value<String> midBreakAlarmMinutes,
});

final class $$BreakTypesTableReferences
    extends BaseReferences<_$AppDatabase, $BreakTypesTable, BreakType> {
  $$BreakTypesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$ActivitiesTable, List<Activity>>
  _activitiesRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.activities,
    aliasName: 'break_types__id__activities__break_type_id',
  );

  $$ActivitiesTableProcessedTableManager get activitiesRefs {
    final manager = $$ActivitiesTableTableManager(
      $_db,
      $_db.activities,
    ).filter((f) => f.breakTypeId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_activitiesRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$BreakTypesTableFilterComposer
    extends Composer<_$AppDatabase, $BreakTypesTable> {
  $$BreakTypesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get colorValue => $composableBuilder(
    column: $table.colorValue,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isDefault => $composableBuilder(
    column: $table.isDefault,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isActive => $composableBuilder(
    column: $table.isActive,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get alarmEnabled => $composableBuilder(
    column: $table.alarmEnabled,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get expectedDurationMinutes => $composableBuilder(
    column: $table.expectedDurationMinutes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<AlarmSound, AlarmSound, String>
  get alarmSound => $composableBuilder(
    column: $table.alarmSound,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<bool> get vibrationEnabled => $composableBuilder(
    column: $table.vibrationEnabled,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<AlarmAlertStyle, AlarmAlertStyle, String>
  get alertStyle => $composableBuilder(
    column: $table.alertStyle,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnWithTypeConverterFilters<ReminderBehaviour, ReminderBehaviour, String>
  get reminderBehaviour => $composableBuilder(
    column: $table.reminderBehaviour,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<int> get repeatIntervalMinutes => $composableBuilder(
    column: $table.repeatIntervalMinutes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get midBreakAlarmMinutes => $composableBuilder(
    column: $table.midBreakAlarmMinutes,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> activitiesRefs(
    Expression<bool> Function($$ActivitiesTableFilterComposer f) f,
  ) {
    final $$ActivitiesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.activities,
      getReferencedColumn: (t) => t.breakTypeId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ActivitiesTableFilterComposer(
            $db: $db,
            $table: $db.activities,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$BreakTypesTableOrderingComposer
    extends Composer<_$AppDatabase, $BreakTypesTable> {
  $$BreakTypesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get colorValue => $composableBuilder(
    column: $table.colorValue,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isDefault => $composableBuilder(
    column: $table.isDefault,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isActive => $composableBuilder(
    column: $table.isActive,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get alarmEnabled => $composableBuilder(
    column: $table.alarmEnabled,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get expectedDurationMinutes => $composableBuilder(
    column: $table.expectedDurationMinutes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get alarmSound => $composableBuilder(
    column: $table.alarmSound,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get vibrationEnabled => $composableBuilder(
    column: $table.vibrationEnabled,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get alertStyle => $composableBuilder(
    column: $table.alertStyle,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get reminderBehaviour => $composableBuilder(
    column: $table.reminderBehaviour,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get repeatIntervalMinutes => $composableBuilder(
    column: $table.repeatIntervalMinutes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get midBreakAlarmMinutes => $composableBuilder(
    column: $table.midBreakAlarmMinutes,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$BreakTypesTableAnnotationComposer
    extends Composer<_$AppDatabase, $BreakTypesTable> {
  $$BreakTypesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => column,
  );

  GeneratedColumn<int> get colorValue => $composableBuilder(
    column: $table.colorValue,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isDefault =>
      $composableBuilder(column: $table.isDefault, builder: (column) => column);

  GeneratedColumn<bool> get isActive =>
      $composableBuilder(column: $table.isActive, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<bool> get alarmEnabled => $composableBuilder(
    column: $table.alarmEnabled,
    builder: (column) => column,
  );

  GeneratedColumn<int> get expectedDurationMinutes => $composableBuilder(
    column: $table.expectedDurationMinutes,
    builder: (column) => column,
  );

  GeneratedColumnWithTypeConverter<AlarmSound, String> get alarmSound =>
      $composableBuilder(
        column: $table.alarmSound,
        builder: (column) => column,
      );

  GeneratedColumn<bool> get vibrationEnabled => $composableBuilder(
    column: $table.vibrationEnabled,
    builder: (column) => column,
  );

  GeneratedColumnWithTypeConverter<AlarmAlertStyle, String> get alertStyle =>
      $composableBuilder(
        column: $table.alertStyle,
        builder: (column) => column,
      );

  GeneratedColumnWithTypeConverter<ReminderBehaviour, String>
  get reminderBehaviour => $composableBuilder(
    column: $table.reminderBehaviour,
    builder: (column) => column,
  );

  GeneratedColumn<int> get repeatIntervalMinutes => $composableBuilder(
    column: $table.repeatIntervalMinutes,
    builder: (column) => column,
  );

  GeneratedColumn<String> get midBreakAlarmMinutes => $composableBuilder(
    column: $table.midBreakAlarmMinutes,
    builder: (column) => column,
  );

  Expression<T> activitiesRefs<T extends Object>(
    Expression<T> Function($$ActivitiesTableAnnotationComposer a) f,
  ) {
    final $$ActivitiesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.activities,
      getReferencedColumn: (t) => t.breakTypeId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ActivitiesTableAnnotationComposer(
            $db: $db,
            $table: $db.activities,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$BreakTypesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $BreakTypesTable,
          BreakType,
          $$BreakTypesTableFilterComposer,
          $$BreakTypesTableOrderingComposer,
          $$BreakTypesTableAnnotationComposer,
          $$BreakTypesTableCreateCompanionBuilder,
          $$BreakTypesTableUpdateCompanionBuilder,
          (BreakType, $$BreakTypesTableReferences),
          BreakType,
          PrefetchHooks Function({bool activitiesRefs})
        > {
  $$BreakTypesTableTableManager(_$AppDatabase db, $BreakTypesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$BreakTypesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$BreakTypesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$BreakTypesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String?> description = const Value.absent(),
                Value<int?> colorValue = const Value.absent(),
                Value<bool> isDefault = const Value.absent(),
                Value<bool> isActive = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<bool> alarmEnabled = const Value.absent(),
                Value<int> expectedDurationMinutes = const Value.absent(),
                Value<AlarmSound> alarmSound = const Value.absent(),
                Value<bool> vibrationEnabled = const Value.absent(),
                Value<AlarmAlertStyle> alertStyle = const Value.absent(),
                Value<ReminderBehaviour> reminderBehaviour =
                    const Value.absent(),
                Value<int> repeatIntervalMinutes = const Value.absent(),
                Value<String> midBreakAlarmMinutes = const Value.absent(),
              }) => BreakTypesCompanion(
                id: id,
                name: name,
                description: description,
                colorValue: colorValue,
                isDefault: isDefault,
                isActive: isActive,
                createdAt: createdAt,
                alarmEnabled: alarmEnabled,
                expectedDurationMinutes: expectedDurationMinutes,
                alarmSound: alarmSound,
                vibrationEnabled: vibrationEnabled,
                alertStyle: alertStyle,
                reminderBehaviour: reminderBehaviour,
                repeatIntervalMinutes: repeatIntervalMinutes,
                midBreakAlarmMinutes: midBreakAlarmMinutes,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String name,
                Value<String?> description = const Value.absent(),
                Value<int?> colorValue = const Value.absent(),
                Value<bool> isDefault = const Value.absent(),
                Value<bool> isActive = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<bool> alarmEnabled = const Value.absent(),
                Value<int> expectedDurationMinutes = const Value.absent(),
                Value<AlarmSound> alarmSound = const Value.absent(),
                Value<bool> vibrationEnabled = const Value.absent(),
                Value<AlarmAlertStyle> alertStyle = const Value.absent(),
                Value<ReminderBehaviour> reminderBehaviour =
                    const Value.absent(),
                Value<int> repeatIntervalMinutes = const Value.absent(),
                Value<String> midBreakAlarmMinutes = const Value.absent(),
              }) => BreakTypesCompanion.insert(
                id: id,
                name: name,
                description: description,
                colorValue: colorValue,
                isDefault: isDefault,
                isActive: isActive,
                createdAt: createdAt,
                alarmEnabled: alarmEnabled,
                expectedDurationMinutes: expectedDurationMinutes,
                alarmSound: alarmSound,
                vibrationEnabled: vibrationEnabled,
                alertStyle: alertStyle,
                reminderBehaviour: reminderBehaviour,
                repeatIntervalMinutes: repeatIntervalMinutes,
                midBreakAlarmMinutes: midBreakAlarmMinutes,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$BreakTypesTable, BreakType>(table),
                  $$BreakTypesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({activitiesRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (activitiesRefs) db.activities],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (activitiesRefs)
                    await $_getPrefetchedDataByColumns<
                      BreakType,
                      $BreakTypesTable,
                      Activity,
                      $ActivitiesTable
                    >(
                      currentTable: table,
                      referencedTable: $$BreakTypesTableReferences
                          ._activitiesRefsTable(db),
                      managerFromTypedResult: (p0) =>
                          $$BreakTypesTableReferences(
                            db,
                            table,
                            p0,
                          ).activitiesRefs,
                      currentColumn: 'id',
                      referencedColumn: 'break_type_id',
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$BreakTypesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $BreakTypesTable,
      BreakType,
      $$BreakTypesTableFilterComposer,
      $$BreakTypesTableOrderingComposer,
      $$BreakTypesTableAnnotationComposer,
      $$BreakTypesTableCreateCompanionBuilder,
      $$BreakTypesTableUpdateCompanionBuilder,
      (BreakType, $$BreakTypesTableReferences),
      BreakType,
      PrefetchHooks Function({bool activitiesRefs})
    >;
typedef $$ActivitiesTableCreateCompanionBuilder = ActivitiesCompanion Function({
  Value<int> id,
  required ActivityKind kind,
  Value<int?> breakTypeId,
  required DateTime startTime,
  Value<DateTime?> endTime,
  Value<int?> durationSeconds,
  required String dayKey,
  Value<int?> targetMinutes,
});
typedef $$ActivitiesTableUpdateCompanionBuilder = ActivitiesCompanion Function({
  Value<int> id,
  Value<ActivityKind> kind,
  Value<int?> breakTypeId,
  Value<DateTime> startTime,
  Value<DateTime?> endTime,
  Value<int?> durationSeconds,
  Value<String> dayKey,
  Value<int?> targetMinutes,
});

final class $$ActivitiesTableReferences
    extends BaseReferences<_$AppDatabase, $ActivitiesTable, Activity> {
  $$ActivitiesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $BreakTypesTable _breakTypeIdTable(_$AppDatabase db) =>
      db.breakTypes.createAlias('activities__break_type_id__break_types__id');

  $$BreakTypesTableProcessedTableManager? get breakTypeId {
    final $_column = $_itemColumn<int>('break_type_id');
    if ($_column == null) return null;
    final manager = $$BreakTypesTableTableManager(
      $_db,
      $_db.breakTypes,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_breakTypeIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$ActivitiesTableFilterComposer
    extends Composer<_$AppDatabase, $ActivitiesTable> {
  $$ActivitiesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<ActivityKind, ActivityKind, String> get kind =>
      $composableBuilder(
        column: $table.kind,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnFilters<DateTime> get startTime => $composableBuilder(
    column: $table.startTime,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get endTime => $composableBuilder(
    column: $table.endTime,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get durationSeconds => $composableBuilder(
    column: $table.durationSeconds,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get dayKey => $composableBuilder(
    column: $table.dayKey,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get targetMinutes => $composableBuilder(
    column: $table.targetMinutes,
    builder: (column) => ColumnFilters(column),
  );

  $$BreakTypesTableFilterComposer get breakTypeId {
    final $$BreakTypesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.breakTypeId,
      referencedTable: $db.breakTypes,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$BreakTypesTableFilterComposer(
            $db: $db,
            $table: $db.breakTypes,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ActivitiesTableOrderingComposer
    extends Composer<_$AppDatabase, $ActivitiesTable> {
  $$ActivitiesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get kind => $composableBuilder(
    column: $table.kind,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get startTime => $composableBuilder(
    column: $table.startTime,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get endTime => $composableBuilder(
    column: $table.endTime,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get durationSeconds => $composableBuilder(
    column: $table.durationSeconds,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get dayKey => $composableBuilder(
    column: $table.dayKey,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get targetMinutes => $composableBuilder(
    column: $table.targetMinutes,
    builder: (column) => ColumnOrderings(column),
  );

  $$BreakTypesTableOrderingComposer get breakTypeId {
    final $$BreakTypesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.breakTypeId,
      referencedTable: $db.breakTypes,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$BreakTypesTableOrderingComposer(
            $db: $db,
            $table: $db.breakTypes,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ActivitiesTableAnnotationComposer
    extends Composer<_$AppDatabase, $ActivitiesTable> {
  $$ActivitiesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumnWithTypeConverter<ActivityKind, String> get kind =>
      $composableBuilder(column: $table.kind, builder: (column) => column);

  GeneratedColumn<DateTime> get startTime =>
      $composableBuilder(column: $table.startTime, builder: (column) => column);

  GeneratedColumn<DateTime> get endTime =>
      $composableBuilder(column: $table.endTime, builder: (column) => column);

  GeneratedColumn<int> get durationSeconds => $composableBuilder(
    column: $table.durationSeconds,
    builder: (column) => column,
  );

  GeneratedColumn<String> get dayKey =>
      $composableBuilder(column: $table.dayKey, builder: (column) => column);

  GeneratedColumn<int> get targetMinutes => $composableBuilder(
    column: $table.targetMinutes,
    builder: (column) => column,
  );

  $$BreakTypesTableAnnotationComposer get breakTypeId {
    final $$BreakTypesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.breakTypeId,
      referencedTable: $db.breakTypes,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$BreakTypesTableAnnotationComposer(
            $db: $db,
            $table: $db.breakTypes,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ActivitiesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ActivitiesTable,
          Activity,
          $$ActivitiesTableFilterComposer,
          $$ActivitiesTableOrderingComposer,
          $$ActivitiesTableAnnotationComposer,
          $$ActivitiesTableCreateCompanionBuilder,
          $$ActivitiesTableUpdateCompanionBuilder,
          (Activity, $$ActivitiesTableReferences),
          Activity,
          PrefetchHooks Function({bool breakTypeId})
        > {
  $$ActivitiesTableTableManager(_$AppDatabase db, $ActivitiesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ActivitiesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ActivitiesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ActivitiesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<ActivityKind> kind = const Value.absent(),
                Value<int?> breakTypeId = const Value.absent(),
                Value<DateTime> startTime = const Value.absent(),
                Value<DateTime?> endTime = const Value.absent(),
                Value<int?> durationSeconds = const Value.absent(),
                Value<String> dayKey = const Value.absent(),
                Value<int?> targetMinutes = const Value.absent(),
              }) => ActivitiesCompanion(
                id: id,
                kind: kind,
                breakTypeId: breakTypeId,
                startTime: startTime,
                endTime: endTime,
                durationSeconds: durationSeconds,
                dayKey: dayKey,
                targetMinutes: targetMinutes,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required ActivityKind kind,
                Value<int?> breakTypeId = const Value.absent(),
                required DateTime startTime,
                Value<DateTime?> endTime = const Value.absent(),
                Value<int?> durationSeconds = const Value.absent(),
                required String dayKey,
                Value<int?> targetMinutes = const Value.absent(),
              }) => ActivitiesCompanion.insert(
                id: id,
                kind: kind,
                breakTypeId: breakTypeId,
                startTime: startTime,
                endTime: endTime,
                durationSeconds: durationSeconds,
                dayKey: dayKey,
                targetMinutes: targetMinutes,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$ActivitiesTable, Activity>(table),
                  $$ActivitiesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({breakTypeId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (breakTypeId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.breakTypeId,
                        referencedTable: $$ActivitiesTableReferences
                            ._breakTypeIdTable(db),
                        referencedColumn: $$ActivitiesTableReferences
                            ._breakTypeIdTable(db)
                            .id,
                      ) as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$ActivitiesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ActivitiesTable,
      Activity,
      $$ActivitiesTableFilterComposer,
      $$ActivitiesTableOrderingComposer,
      $$ActivitiesTableAnnotationComposer,
      $$ActivitiesTableCreateCompanionBuilder,
      $$ActivitiesTableUpdateCompanionBuilder,
      (Activity, $$ActivitiesTableReferences),
      Activity,
      PrefetchHooks Function({bool breakTypeId})
    >;
typedef $$AppSettingsTableCreateCompanionBuilder =
    AppSettingsCompanion Function({
      Value<int> id,
      Value<int> dailyTargetMinutes,
      Value<int> allowedBreakMinutes,
    });
typedef $$AppSettingsTableUpdateCompanionBuilder =
    AppSettingsCompanion Function({
      Value<int> id,
      Value<int> dailyTargetMinutes,
      Value<int> allowedBreakMinutes,
    });

class $$AppSettingsTableFilterComposer
    extends Composer<_$AppDatabase, $AppSettingsTable> {
  $$AppSettingsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get dailyTargetMinutes => $composableBuilder(
    column: $table.dailyTargetMinutes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get allowedBreakMinutes => $composableBuilder(
    column: $table.allowedBreakMinutes,
    builder: (column) => ColumnFilters(column),
  );
}

class $$AppSettingsTableOrderingComposer
    extends Composer<_$AppDatabase, $AppSettingsTable> {
  $$AppSettingsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get dailyTargetMinutes => $composableBuilder(
    column: $table.dailyTargetMinutes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get allowedBreakMinutes => $composableBuilder(
    column: $table.allowedBreakMinutes,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$AppSettingsTableAnnotationComposer
    extends Composer<_$AppDatabase, $AppSettingsTable> {
  $$AppSettingsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get dailyTargetMinutes => $composableBuilder(
    column: $table.dailyTargetMinutes,
    builder: (column) => column,
  );

  GeneratedColumn<int> get allowedBreakMinutes => $composableBuilder(
    column: $table.allowedBreakMinutes,
    builder: (column) => column,
  );
}

class $$AppSettingsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $AppSettingsTable,
          AppSetting,
          $$AppSettingsTableFilterComposer,
          $$AppSettingsTableOrderingComposer,
          $$AppSettingsTableAnnotationComposer,
          $$AppSettingsTableCreateCompanionBuilder,
          $$AppSettingsTableUpdateCompanionBuilder,
          (
            AppSetting,
            BaseReferences<_$AppDatabase, $AppSettingsTable, AppSetting>,
          ),
          AppSetting,
          PrefetchHooks Function()
        > {
  $$AppSettingsTableTableManager(_$AppDatabase db, $AppSettingsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AppSettingsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AppSettingsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AppSettingsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> dailyTargetMinutes = const Value.absent(),
                Value<int> allowedBreakMinutes = const Value.absent(),
              }) => AppSettingsCompanion(
                id: id,
                dailyTargetMinutes: dailyTargetMinutes,
                allowedBreakMinutes: allowedBreakMinutes,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> dailyTargetMinutes = const Value.absent(),
                Value<int> allowedBreakMinutes = const Value.absent(),
              }) => AppSettingsCompanion.insert(
                id: id,
                dailyTargetMinutes: dailyTargetMinutes,
                allowedBreakMinutes: allowedBreakMinutes,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$AppSettingsTable, AppSetting>(table),
                  BaseReferences<_$AppDatabase, $AppSettingsTable, AppSetting>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$AppSettingsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $AppSettingsTable,
      AppSetting,
      $$AppSettingsTableFilterComposer,
      $$AppSettingsTableOrderingComposer,
      $$AppSettingsTableAnnotationComposer,
      $$AppSettingsTableCreateCompanionBuilder,
      $$AppSettingsTableUpdateCompanionBuilder,
      (
        AppSetting,
        BaseReferences<_$AppDatabase, $AppSettingsTable, AppSetting>,
      ),
      AppSetting,
      PrefetchHooks Function()
    >;
typedef $$TasksTableCreateCompanionBuilder = TasksCompanion Function({
  Value<int> id,
  required String title,
  Value<String?> notes,
  Value<DateTime?> dueAt,
  Value<String?> locationName,
  Value<double?> latitude,
  Value<double?> longitude,
  Value<int?> radiusMeters,
  Value<bool> isDone,
  Value<DateTime> createdAt,
});
typedef $$TasksTableUpdateCompanionBuilder = TasksCompanion Function({
  Value<int> id,
  Value<String> title,
  Value<String?> notes,
  Value<DateTime?> dueAt,
  Value<String?> locationName,
  Value<double?> latitude,
  Value<double?> longitude,
  Value<int?> radiusMeters,
  Value<bool> isDone,
  Value<DateTime> createdAt,
});

class $$TasksTableFilterComposer extends Composer<_$AppDatabase, $TasksTable> {
  $$TasksTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get dueAt => $composableBuilder(
    column: $table.dueAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get locationName => $composableBuilder(
    column: $table.locationName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get latitude => $composableBuilder(
    column: $table.latitude,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get longitude => $composableBuilder(
    column: $table.longitude,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get radiusMeters => $composableBuilder(
    column: $table.radiusMeters,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isDone => $composableBuilder(
    column: $table.isDone,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$TasksTableOrderingComposer
    extends Composer<_$AppDatabase, $TasksTable> {
  $$TasksTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get dueAt => $composableBuilder(
    column: $table.dueAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get locationName => $composableBuilder(
    column: $table.locationName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get latitude => $composableBuilder(
    column: $table.latitude,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get longitude => $composableBuilder(
    column: $table.longitude,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get radiusMeters => $composableBuilder(
    column: $table.radiusMeters,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isDone => $composableBuilder(
    column: $table.isDone,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$TasksTableAnnotationComposer
    extends Composer<_$AppDatabase, $TasksTable> {
  $$TasksTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  GeneratedColumn<DateTime> get dueAt =>
      $composableBuilder(column: $table.dueAt, builder: (column) => column);

  GeneratedColumn<String> get locationName => $composableBuilder(
    column: $table.locationName,
    builder: (column) => column,
  );

  GeneratedColumn<double> get latitude =>
      $composableBuilder(column: $table.latitude, builder: (column) => column);

  GeneratedColumn<double> get longitude =>
      $composableBuilder(column: $table.longitude, builder: (column) => column);

  GeneratedColumn<int> get radiusMeters => $composableBuilder(
    column: $table.radiusMeters,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isDone =>
      $composableBuilder(column: $table.isDone, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$TasksTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $TasksTable,
          Task,
          $$TasksTableFilterComposer,
          $$TasksTableOrderingComposer,
          $$TasksTableAnnotationComposer,
          $$TasksTableCreateCompanionBuilder,
          $$TasksTableUpdateCompanionBuilder,
          (Task, BaseReferences<_$AppDatabase, $TasksTable, Task>),
          Task,
          PrefetchHooks Function()
        > {
  $$TasksTableTableManager(_$AppDatabase db, $TasksTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TasksTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TasksTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TasksTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<DateTime?> dueAt = const Value.absent(),
                Value<String?> locationName = const Value.absent(),
                Value<double?> latitude = const Value.absent(),
                Value<double?> longitude = const Value.absent(),
                Value<int?> radiusMeters = const Value.absent(),
                Value<bool> isDone = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => TasksCompanion(
                id: id,
                title: title,
                notes: notes,
                dueAt: dueAt,
                locationName: locationName,
                latitude: latitude,
                longitude: longitude,
                radiusMeters: radiusMeters,
                isDone: isDone,
                createdAt: createdAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String title,
                Value<String?> notes = const Value.absent(),
                Value<DateTime?> dueAt = const Value.absent(),
                Value<String?> locationName = const Value.absent(),
                Value<double?> latitude = const Value.absent(),
                Value<double?> longitude = const Value.absent(),
                Value<int?> radiusMeters = const Value.absent(),
                Value<bool> isDone = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => TasksCompanion.insert(
                id: id,
                title: title,
                notes: notes,
                dueAt: dueAt,
                locationName: locationName,
                latitude: latitude,
                longitude: longitude,
                radiusMeters: radiusMeters,
                isDone: isDone,
                createdAt: createdAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$TasksTable, Task>(table),
                  BaseReferences<_$AppDatabase, $TasksTable, Task>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$TasksTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $TasksTable,
      Task,
      $$TasksTableFilterComposer,
      $$TasksTableOrderingComposer,
      $$TasksTableAnnotationComposer,
      $$TasksTableCreateCompanionBuilder,
      $$TasksTableUpdateCompanionBuilder,
      (Task, BaseReferences<_$AppDatabase, $TasksTable, Task>),
      Task,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$BreakTypesTableTableManager get breakTypes =>
      $$BreakTypesTableTableManager(_db, _db.breakTypes);
  $$ActivitiesTableTableManager get activities =>
      $$ActivitiesTableTableManager(_db, _db.activities);
  $$AppSettingsTableTableManager get appSettings =>
      $$AppSettingsTableTableManager(_db, _db.appSettings);
  $$TasksTableTableManager get tasks =>
      $$TasksTableTableManager(_db, _db.tasks);
}
