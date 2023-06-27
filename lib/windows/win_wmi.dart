// ignore_for_file: constant_identifier_names, non_constant_identifier_names

import 'dart:developer';
import 'dart:ffi';

import 'package:ffi/ffi.dart';
import 'package:win32/win32.dart';

/// Call WMI queries
/// The COM library is never closed (TODO should change?)
class WinWMI {

  static const String _namespace = r'ROOT\CIMV2';
  static int _failPoint = 0;

  static String? queryString(String valName, String wmiClass) {
    IWbemServices? service = _service;
    if (service == null) return null;

    final pEnumerator = calloc<Pointer<COMObject>>();
    IEnumWbemClassObject? enumerator;

    try {
      // For example, query for all the running processes
      int hr = service.execQuery(TEXT('WQL'), TEXT('SELECT $valName FROM $wmiClass'),
          WBEM_GENERIC_FLAG_TYPE.WBEM_FLAG_FORWARD_ONLY | WBEM_GENERIC_FLAG_TYPE.WBEM_FLAG_RETURN_IMMEDIATELY, nullptr, pEnumerator);

      if (FAILED(hr)) {
        log(WindowsException(hr).toString(), level: 1000);
        free(pEnumerator);
        return null;
      } else {
        enumerator = IEnumWbemClassObject(pEnumerator.cast());

        final uReturn = calloc<Uint32>();

        if (enumerator.ptr.address > 0) {
          final pClsObj = calloc<IntPtr>();
          hr = enumerator.next(WBEM_TIMEOUT_TYPE.WBEM_INFINITE, 1, pClsObj.cast(), uReturn);

          // Break out of the while loop if we've run out of processes to inspect
          if (uReturn.value == 0) {
            free(pClsObj);
            return null;
          }

          final clsObj = IWbemClassObject(pClsObj.cast());

          final vtProp = calloc<VARIANT>();
          hr = clsObj.get(TEXT(valName), 0, vtProp, nullptr, nullptr);
          String? value = SUCCEEDED(hr) ? vtProp.ref.bstrVal.toDartString() : null;
          
          VariantClear(vtProp);
          free(vtProp);
          clsObj.release();

          return value;
        }
      }
    }
    finally {
      enumerator?.release() ?? free(pEnumerator);
    }
  }

  static IWbemServices? get _service => __serviceResult ?? _initService();
  static IWbemServices? __serviceResult;
  
  static IWbemServices? _initService() {
    if (__serviceResult != null) return __serviceResult;
    int hr = 0;

    if (_failPoint < 1) {
      hr = CoInitializeEx(nullptr, COINIT_APARTMENTTHREADED);
      if (FAILED(hr)) {
        log(WindowsException(hr).toString(), level: 1000);
        return null;
      }
    }

    if (_failPoint < 1) _failPoint = 1;

    // Initialize security model
    if (_failPoint < 2) {
      hr = CoInitializeSecurity(nullptr, -1, nullptr, nullptr, RPC_C_AUTHN_LEVEL_DEFAULT, RPC_C_IMP_LEVEL_IMPERSONATE, // Impersonation
          nullptr, EOLE_AUTHENTICATION_CAPABILITIES.EOAC_NONE, nullptr);

      if (FAILED(hr)) {
        log(WindowsException(hr).toString(), level: 1000);
        CoUninitialize();
        return null;
      }
    }

    if (_failPoint < 2) _failPoint = 2;

    // Obtain the initial locator to Windows Management
    // on a particular host computer.
    final pLoc = IWbemLocator(calloc<COMObject>());

    final clsid = malloc<GUID>()..ref.setGUID(CLSID_WbemLocator);
    final iid = malloc<GUID>()..ref.setGUID(IID_IWbemLocator);

    hr = CoCreateInstance(clsid, nullptr, CLSCTX_INPROC_SERVER, iid, pLoc.ptr.cast());

    if (FAILED(hr)) {
      log(WindowsException(hr).toString(), level: 1000);

      pLoc.release();
      free(clsid);
      free(iid);
      CoUninitialize();
      return null;
    }

    final proxy = calloc<Pointer<COMObject>>();

    // Connect to the root\cimv2 namespace with the
    // current user and obtain pointer pSvc
    // to make IWbemServices calls.
    hr = pLoc.connectServer(TEXT(_namespace), nullptr, nullptr, nullptr, NULL, nullptr, nullptr, proxy);

    if (FAILED(hr)) {
      log(WindowsException(hr).toString(), level: 1000);

      pLoc.release();
      free(clsid);
      free(iid);
      free(proxy);
      CoUninitialize();
      return null; // Program has failed.
    }

    log(r'Connected to ROOT\CIMV2 WMI namespace');

    return __serviceResult = IWbemServices(proxy.cast());

    // Set the IWbemServices proxy so that impersonation
    // of the user (client) occurs.
    /*hr = CoSetProxyBlanket(
        proxy.value, // the proxy to set
        RPC_C_AUTHN_WINNT, // authentication service
        RPC_C_AUTHZ_NONE, // authorization service
        nullptr, // Server principal name
        RPC_C_AUTHN_LEVEL_CALL, // authentication level
        RPC_C_IMP_LEVEL_IMPERSONATE, // impersonation level
        nullptr, // client identity
        EOLE_AUTHENTICATION_CAPABILITIES.EOAC_NONE // proxy capabilities
        );

    if (FAILED(hr)) {
      final exception = WindowsException(hr);
      print(exception.toString());
      pSvc.Release();
      pLoc.Release();
      CoUninitialize();
      throw exception; // Program has failed.
    }*/
  }
}