#include <Windows.h>
#include <csignal>
#include <iostream>

LRESULT CALLBACK KeyboardProc(int nCode, WPARAM wParam, LPARAM lParam) {
  if (nCode == HC_ACTION) {
    KBDLLHOOKSTRUCT *pKeyboard = (KBDLLHOOKSTRUCT *)lParam;

    if (pKeyboard->vkCode == VK_ESCAPE) {
      exit(0);
    }
    if (pKeyboard->vkCode == VK_F8) {
      if (wParam == WM_KEYDOWN) {
        std::cout << "Key Pressed: " << pKeyboard->vkCode
                  << std::endl; // 按下事件
        keybd_event(VK_RCONTROL, 0, KEYEVENTF_KEYUP, 0);
      }
    }
    if (pKeyboard->vkCode == VK_F9) {
      if (wParam == WM_KEYDOWN) {
        std::cout << "Key Pressed: " << pKeyboard->vkCode
                  << std::endl; // 按下事件
        keybd_event(VK_RCONTROL, 0, 0, 0);
      }
    }
  }
  return CallNextHookEx(NULL, nCode, wParam, lParam);
}

struct KeyboarListener {
  int start_key_, control_key_;
  HHOOK hhkLowLevelKeyboard;

  KeyboarListener(int start_key, int control_key)
      : start_key_(start_key), control_key_(control_key) {
    hhkLowLevelKeyboard =
        SetWindowsHookEx(WH_KEYBOARD_LL, KeyboardProc, NULL, 0);
    if (hhkLowLevelKeyboard == NULL) {
      std::cerr << "Failed to install hook!" << std::endl;
      return;
    }
  }
  ~KeyboarListener() {
    std::cout << "deconstructor" << std::endl;
    KeyUp();
    UnhookWindowsHookEx(hhkLowLevelKeyboard);
  }

  void KeyDown() {
    while (true) {
      MSG msg;
      while (GetMessage(&msg, NULL, 0, 0)) {
        TranslateMessage(&msg);
        DispatchMessage(&msg);
      }
    }
  }
  void KeyUp() { keybd_event(VK_RCONTROL, 0, KEYEVENTF_KEYUP, 0); }
};

KeyboarListener *kl = new KeyboarListener(VK_F9, VK_CONTROL);

void clean(int sig) {
  delete kl;
  exit(sig);
}
void clean() { delete kl; }

int main(int argc, char **argv) {
  std::cout << "print params:\n";
  for (size_t i = 0; i < argc; i++) {
    std::cout << "arg[" << i << "]: " << argv[i] << "\n";
  }
  std::cout << std::endl;

  signal(SIGINT, clean);
  signal(SIGTERM, clean);
  atexit(clean);

  kl->KeyDown();
  return 0;
}