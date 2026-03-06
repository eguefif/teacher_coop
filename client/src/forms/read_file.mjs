import { BitArray } from "../gleam.mjs";

export function read_file(file, dispatch) {
  const reader = new FileReader();
  reader.onload = (e) =>
    dispatch(new BitArray(new Uint8Array(e.target.result)));
  reader.readAsArrayBuffer(file);
}
