#include <Windows.h>
#include <csignal>
#include <iomanip>
#include <iostream>
#include <string>
#include <vector>

struct KeyboarListener;

KeyboarListener *g_kl = nullptr;

LRESULT CALLBACK KeyboardProc(int nCode, WPARAM wParam, LPARAM lParam);

struct KeyboarListener {
  int start_key_, control_key_, end_key_;
  HHOOK hhkLowLevelKeyboard;

  KeyboarListener(int start_key, int control_key, int end_key)
      : start_key_(start_key), control_key_(control_key), end_key_(end_key) {
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
  void KeyUp() { keybd_event(control_key_, 0, KEYEVENTF_KEYUP, 0); }
};

LRESULT CALLBACK KeyboardProc(int nCode, WPARAM wParam, LPARAM lParam) {
  if (nCode == HC_ACTION) {
    KBDLLHOOKSTRUCT *pKeyboard = (KBDLLHOOKSTRUCT *)lParam;

    if (pKeyboard->vkCode == VK_ESCAPE) {
      exit(0);
    }
    if (pKeyboard->vkCode == g_kl->end_key_) {
      if (wParam == WM_KEYDOWN) {
        std::cout << "Key Pressed: " << pKeyboard->vkCode
                  << std::endl; // 按下事件
        keybd_event(g_kl->control_key_, 0, KEYEVENTF_KEYUP, 0);
      }
    }
    if (pKeyboard->vkCode == g_kl->start_key_) {
      if (wParam == WM_KEYDOWN) {
        std::cout << "Key Pressed: " << pKeyboard->vkCode
                  << std::endl; // 按下事件
        keybd_event(g_kl->control_key_, 0, 0, 0);
      }
    }
  }
  return CallNextHookEx(NULL, nCode, wParam, lParam);
}

void clean(int sig) {
  if (g_kl)
    delete g_kl;
  exit(sig);
}
void clean() {
  if (g_kl)
    delete g_kl;
}

int main(int argc, char **argv) {
  std::cout << "print params:\n";
  std::vector<int32_t> params;
  for (size_t i = 1; i < argc; i++) {
    std::cout << "arg[" << i << "]: " << argv[i] << "\n";
    int num = 0;
    if (*argv[i] == '0') {
      if (strlen(argv[i]) >= 2 && *(argv[i] + 1) == 'x') {
        num = std::stoi(argv[i], nullptr, 16);
      } else if (strlen(argv[i]) >= 2 && *(argv[i] + 1) == 'b') {
        num = std::stoi(argv[i], nullptr, 2);
      } else if (strlen(argv[i]) > 1) {
        num = std::stoi(argv[i], nullptr, 8);
      }
    } else {
      num = std::stoi(argv[i]);
    }
    params.emplace_back(num);
  }
  std::cout << std::endl;

  if (params.size() < 3) {
    std::cout << "参数数量不满足 3 个" << std::endl;
    return -1;
  }

  std::cout << "params: " << params[0] << ", " << params[1] << ", " << params[2]
            << std::endl;

  g_kl = new KeyboarListener(params[0], params[1], params[2]);

  signal(SIGINT, clean);
  atexit(clean);

  g_kl->KeyDown();
  return 0;
}