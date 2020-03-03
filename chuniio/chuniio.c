#include <windows.h>

#include <process.h>
#include <stdbool.h>
#include <stdint.h>

#include "chuniio/chuniio.h"
#include "chuniio/config.h"

static unsigned int __stdcall chuni_io_slider_thread_proc(void *ctx);

static bool chuni_io_coin;
static uint16_t chuni_io_coins;
static HANDLE chuni_io_slider_thread;
static bool chuni_io_slider_stop_flag;
static struct chuni_io_config chuni_io_cfg;

struct IPCMemoryInfo
{
    uint8_t airIoStatus[6];
    uint8_t sliderIoStatus[32];
    uint8_t ledRgbData[32 * 3];
};
typedef struct IPCMemoryInfo IPCMemoryInfo;
static HANDLE FileMappingHandle;
IPCMemoryInfo* FileMapping;

void initSharedMemory()
{
    if (FileMapping)
    {
        return;
    }
    if ((FileMappingHandle = CreateFileMapping(INVALID_HANDLE_VALUE, 0, PAGE_READWRITE, 0, sizeof(IPCMemoryInfo), "Local\\BROKENITHM_SHARED_BUFFER")) == 0)
    {
        return;
    }

    if ((FileMapping = (IPCMemoryInfo*)MapViewOfFile(FileMappingHandle, FILE_MAP_ALL_ACCESS, 0, 0, sizeof(IPCMemoryInfo))) == 0)
    {
        return;
    }

    memset(FileMapping, 0, sizeof(IPCMemoryInfo));
    SetThreadExecutionState(ES_DISPLAY_REQUIRED | ES_CONTINUOUS);
}

HRESULT chuni_io_jvs_init(void)
{
    chuni_io_config_load(&chuni_io_cfg, L".\\segatools.ini");

    initSharedMemory();

    return S_OK;
}

void chuni_io_jvs_read_coin_counter(uint16_t *out)
{
    if (out == NULL) {
        return;
    }

    if (GetAsyncKeyState(chuni_io_cfg.vk_coin)) {
        if (!chuni_io_coin) {
            chuni_io_coin = true;
            chuni_io_coins++;
        }
    } else {
        chuni_io_coin = false;
    }

    *out = chuni_io_coins;
}

void chuni_io_jvs_poll(uint8_t *opbtn, uint8_t *beams)
{
    size_t i;

    if (GetAsyncKeyState(chuni_io_cfg.vk_test)) {
        *opbtn |= 0x01; /* Test */
    }

    if (GetAsyncKeyState(chuni_io_cfg.vk_service)) {
        *opbtn |= 0x02; /* Service */
    }

    for (i = 0 ; i < 6 ; i++) {
        if (FileMapping && FileMapping->airIoStatus[i]) {
            *beams |= (1 << i);
        }
    }
}

void chuni_io_jvs_set_coin_blocker(bool open)
{}

HRESULT chuni_io_slider_init(void)
{
    return S_OK;
}

void chuni_io_slider_start(chuni_io_slider_callback_t callback)
{
    if (chuni_io_slider_thread != NULL) {
        return;
    }

    chuni_io_slider_thread = (HANDLE) _beginthreadex(
            NULL,
            0,
            chuni_io_slider_thread_proc,
            callback,
            0,
            NULL);
}

void chuni_io_slider_stop(void)
{
    if (chuni_io_slider_thread == NULL) {
        return;
    }

    chuni_io_slider_stop_flag = true;

    WaitForSingleObject(chuni_io_slider_thread, INFINITE);
    CloseHandle(chuni_io_slider_thread);
    chuni_io_slider_thread = NULL;
    chuni_io_slider_stop_flag = false;
}

void chuni_io_slider_set_leds(const uint8_t *rgb)
{
    if (FileMapping)
    {
        memcpy(FileMapping->ledRgbData, rgb, 32 * 3);
    }
}

static unsigned int __stdcall chuni_io_slider_thread_proc(void *ctx)
{
    chuni_io_slider_callback_t callback;
    uint8_t pressure[32] = { 0 };

    callback = ctx;

    while (!chuni_io_slider_stop_flag) {
        if (FileMapping) {
            memcpy(pressure, FileMapping->sliderIoStatus, 32);
        }

        callback(pressure);
        Sleep(1);
    }

    return 0;
}
