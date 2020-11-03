//Dart import
import 'package:flutter/material.dart';

//Third party library import

//Local import
import 'state_manager.dart';

class MainStateManager extends ChangeNotifier
    with AssistantManager, AuthManager, LocationManager, DeliveryManager {}
