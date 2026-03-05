export function read_file(file, dispatch) {
  const reader = new FileReader();
  reader.onload = (e) => dispatch(new Uint8Array(e.target.result));
  reader.readAsArrayBuffer(file);
}
