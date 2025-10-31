from qiling import Qiling # main emulator object
from qiling.const import QL_VERBOSE, QL_INTERCEPT
import sys
# from qiling.extensions import pipe
from qiling.os.const import STRING, PARAM_PTRX, PARAM_INT32

# called when the emulated process finishes open
# changes PC to 0x1393C if filename string is empty and open returned a 3
def hook_open(ql: Qiling, pathname_ptr: int, flags: int, mode: int, retval: int):
    print("debug1")
    filename = ql.mem.string(pathname_ptr)
    if filename == '' and retval == 3:
        ql.arch.regs.pc = 0x1393C        

    return None

# fake implementation of scfg_get("G984Serial",&local_110,0x80);
def my_scfg_get(ql: Qiling):
    print("debug2")
    params = ql.os.resolve_fcall_params({'cfg_name': STRING, 'cfg_buffer': PARAM_PTRX, 'buf_size': PARAM_INT32})
    # modify to your serial
    my_serial = b'\x00\x00\x00\x00'

    # Write the bytes to the buffer in the emulated memory
    ql.mem.write(params['cfg_buffer'], my_serial)
    
    return 1

# runs when gen_varlen_vtyshpw() is entered
# decode the call arguments and then print them
def my_gen_varlen_vtyshpw_enter(ql: Qiling):
    print("debug3")
    params = ql.os.resolve_fcall_params({'serial': STRING, 'serial_len': PARAM_INT32, 'dst_len': PARAM_INT32, 'dst': STRING })
    print(params)
    
# runs when gen_varlen_vtyshpw() is exited 
# decode the call arguments and then print them
def my_gen_varlen_vtyshpw_exit(ql: Qiling):
    print("debug4")
    # resolve params as pointers/ints
    params = ql.os.resolve_fcall_params({
        'serial': PARAM_PTRX, 
        'serial_len': STRING, 
        'dst_len': PARAM_INT32, 
        'dst': PARAM_PTRX })
    print(params)

    dst = params.get('dst')
    dst_len = params.get('dst_len')

    if not dst:
        print("no dst pointer")
        return

    # try the easiest: NUL-terminated C string
    try:
        pw = ql.mem.string(dst)
        print("password:", pw)
        return
    except Exception:
        pass

    # fallback: read dst_len bytes if it's a sensible integer, otherwise read up to 256 bytes
    try:
        # be defensive about dst_len type
        if isinstance(dst_len, int) and 0 < dst_len <= 4096:
            n = dst_len
        else:
            n = 256
        raw = ql.mem.read(dst, n)
        s = raw.split(b'\x00', 1)[0].decode('utf-8', errors='replace')
        print("password (fallback read):", s)
    except Exception as e:
        print("failed to read password from memory:", e)

if __name__ == "__main__":
    # set up command line argv and emulated os root path
        # splits the " " into a list; contains vtysh: contains gen_varlen_vtyshpw()
        
    rootfs = r'rootfs'
    argv = r'rootfs/usr/sbin/vtysh -c'.split()  # relative to rootfs, not host path

    # creating Qiling
    ql = Qiling(argv, rootfs, multithread=True, verbose=QL_VERBOSE.DEFAULT)

    # Hook a specific open call to begin jump to target function
    ql.os.set_syscall('open', hook_open, QL_INTERCEPT.EXIT)
    ql.os.set_api("scfg_get", my_scfg_get, QL_INTERCEPT.CALL)
    ql.os.set_api("gen_varlen_vtyshpw", my_gen_varlen_vtyshpw_enter, QL_INTERCEPT.ENTER)
    ql.os.set_api("gen_varlen_vtyshpw", my_gen_varlen_vtyshpw_exit, QL_INTERCEPT.EXIT)

    # starts emulation
    ql.run()
