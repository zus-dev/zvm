import 'package:test/test.dart';
import 'package:zvm/zvm.dart';

import '../helpers.dart';

void main() {
  RingBuffer<int> ringbuffer;

  setUp(() {
    ringbuffer = RingBuffer<int>(3);
  });

  test('Initial', () {
    assertEquals(0, ringbuffer.size());
  });

  test('AddElementNormal', () {
    ringbuffer.add(1);
    assertEquals(1, ringbuffer.size());
    assertEquals(1, ringbuffer.get(0));

    ringbuffer.add(2);
    assertEquals(2, ringbuffer.size());
    assertEquals(2, ringbuffer.get(1));

    ringbuffer.add(3);
    assertEquals(3, ringbuffer.size());
    assertEquals(3, ringbuffer.get(2));

    ringbuffer.set(1, 5);
    assertEquals(3, ringbuffer.size());
    assertEquals(5, ringbuffer.get(1));
  });

  test('AddElementOverflow', () {
    // fill it up to the limit
    ringbuffer.add(1);
    ringbuffer.add(2);
    ringbuffer.add(3);

    // now add one more, the 1 should be gone
    ringbuffer.add(4);
    assertEquals(3, ringbuffer.size());
    assertEquals(4, ringbuffer.get(2));

    ringbuffer.set(0, 7);
    assertEquals(7, ringbuffer.get(0));
  });

  test('RemoveNormal', () {
    ringbuffer.add(1);
    ringbuffer.add(2);
    int elem = ringbuffer.remove(1);
    assertEquals(1, ringbuffer.size());
    assertEquals(2, elem);

    ringbuffer.add(3);
    assertEquals(2, ringbuffer.size());
    assertEquals(3, ringbuffer.get(1));
  });

  test('RemoveOverflow', () {
    // fill it over the limit
    ringbuffer.add(1);
    ringbuffer.add(2);
    ringbuffer.add(3);
    ringbuffer.add(4);

    // contains 2, 3, 4 now
    ringbuffer.remove(1);

    // contains 2, 4 now
    assertEquals(2, ringbuffer.size());
    assertEquals(2, ringbuffer.get(0));
    assertEquals(4, ringbuffer.get(1));
  });

  /**
   * A more sophisticated test that checks whether internal bounds are
   * correctly adjusted.
   */
  test('RemoveTooManyAndReadd', () {
    // overflow the ring buffer
    ringbuffer.add(1);
    ringbuffer.add(2);
    ringbuffer.add(3);
    ringbuffer.add(4);

    // underflow the ring buffer
    ringbuffer.remove(0);
    ringbuffer.remove(0);
    ringbuffer.remove(0);
    ringbuffer.remove(0);

    // size should be 0
    assertEquals(0, ringbuffer.size());

    // adding should work
    ringbuffer.add(5);
    ringbuffer.add(6);
    assertEquals(2, ringbuffer.size());
    assertEquals(5, ringbuffer.get(0));
    assertEquals(6, ringbuffer.get(1));
  });

  test('ToString', () {
    ringbuffer.add(1);
    ringbuffer.add(2);
    assertEquals("{ 1, 2 }", ringbuffer.toString());
  });
}
