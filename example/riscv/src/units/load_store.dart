import 'dart:math';
import 'package:svart/svart.dart';

class LoadStoreUnit extends Module {
  LoadStoreUnit(
    Var operation,
    Var lowAddress,
    Var memData,
    Var regData,
  ) : super(
          definitionName: 'load_store_unit',
          instanceName: 'load_store_unit_instance',
        ) {
    operation = addInput('operation', operation, width: 4);
    lowAddress = addInput('low_address', lowAddress, width: 2);
    memData = addInput('mem_data', memData, width: 32);
    regData = addInput('reg_data', regData, width: 32);
    outputData = addOutput('output_data', width: 32);
    addressMisaligned = addOutput('address_misaligned');

    addCombinational([
      addressMisaligned.assign(Const(0)),
      When([
        Iff(
          operation.eq(
            Const(LoadStoreUnit.operation.lb, width: operation.width),
          ),
          then: [
            When(
              [
                Iff(
                  lowAddress.eq(Const(0, width: lowAddress.width)),
                  then: [
                    If(
                      memData.part(7, 7).eq(Const(1)),
                      then: [
                        outputData.assign(
                          Const(pow(2, 24).toInt() - 1, width: 24)
                              .cat(memData.part(7, 0)),
                        ),
                      ],
                      orElse: [
                        outputData.assign(
                          Const(0, width: 24).cat(memData.part(7, 0)),
                        ),
                      ],
                    ),
                  ],
                ),
                Iff(
                  lowAddress.eq(Const(1, width: lowAddress.width)),
                  then: [
                    If(
                      memData.part(15, 15).eq(Const(1)),
                      then: [
                        outputData.assign(
                          Const(pow(2, 24).toInt() - 1, width: 24)
                              .cat(memData.part(15, 8)),
                        ),
                      ],
                      orElse: [
                        outputData.assign(
                          Const(0, width: 24).cat(memData.part(15, 8)),
                        ),
                      ],
                    ),
                  ],
                ),
                Iff(
                  lowAddress.eq(Const(2, width: lowAddress.width)),
                  then: [
                    If(
                      memData.part(23, 23).eq(Const(1)),
                      then: [
                        outputData.assign(
                          Const(pow(2, 24).toInt() - 1, width: 24)
                              .cat(memData.part(23, 16)),
                        ),
                      ],
                      orElse: [
                        outputData.assign(
                          Const(0, width: 24).cat(memData.part(23, 16)),
                        ),
                      ],
                    ),
                  ],
                ),
                Iff(
                  lowAddress.eq(Const(3, width: lowAddress.width)),
                  then: [
                    If(
                      memData.part(31, 31).eq(Const(1)),
                      then: [
                        outputData.assign(
                          Const(pow(2, 24).toInt() - 1, width: 24)
                              .cat(memData.part(31, 24)),
                        ),
                      ],
                      orElse: [
                        outputData.assign(
                          Const(0, width: 24).cat(memData.part(31, 24)),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
        Iff(
          operation.eq(
            Const(LoadStoreUnit.operation.lh, width: operation.width),
          ),
          then: [
            When(
              [
                Iff(
                  lowAddress.eq(Const(0, width: lowAddress.width)),
                  then: [
                    If(
                      memData.part(15, 15).eq(Const(1)),
                      then: [
                        outputData.assign(
                          Const(pow(2, 16).toInt() - 1, width: 16)
                              .cat(memData.part(15, 0)),
                        ),
                      ],
                      orElse: [
                        outputData.assign(
                          Const(0, width: 16).cat(memData.part(15, 0)),
                        ),
                      ],
                    ),
                  ],
                ),
                Iff(
                  lowAddress.eq(Const(2, width: lowAddress.width)),
                  then: [
                    If(
                      memData.part(31, 31).eq(Const(1)),
                      then: [
                        outputData.assign(
                          Const(pow(2, 16).toInt() - 1, width: 16)
                              .cat(memData.part(31, 16)),
                        ),
                      ],
                      orElse: [
                        outputData.assign(
                          Const(0, width: 16).cat(memData.part(31, 16)),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
              orElse: [
                addressMisaligned.assign(Const(1)),
              ],
            ),
          ],
        ),
        Iff(
          operation.eq(
            Const(LoadStoreUnit.operation.lw, width: operation.width),
          ),
          then: [
            When(
              [
                Iff(
                  lowAddress.eq(Const(0, width: lowAddress.width)),
                  then: [outputData.assign(memData)],
                ),
              ],
              orElse: [
                addressMisaligned.assign(Const(1)),
              ],
            ),
          ],
        ),
        Iff(
          operation.eq(
            Const(LoadStoreUnit.operation.lbu, width: operation.width),
          ),
          then: [
            When(
              [
                Iff(
                  lowAddress.eq(Const(0, width: lowAddress.width)),
                  then: [
                    outputData.assign(
                      Const(0, width: 24).cat(memData.part(7, 0)),
                    ),
                  ],
                ),
                Iff(
                  lowAddress.eq(Const(1, width: lowAddress.width)),
                  then: [
                    outputData.assign(
                      Const(0, width: 24).cat(memData.part(15, 8)),
                    ),
                  ],
                ),
                Iff(
                  lowAddress.eq(Const(2, width: lowAddress.width)),
                  then: [
                    outputData.assign(
                      Const(0, width: 24).cat(memData.part(23, 16)),
                    ),
                  ],
                ),
                Iff(
                  lowAddress.eq(Const(3, width: lowAddress.width)),
                  then: [
                    outputData.assign(
                      Const(0, width: 24).cat(memData.part(31, 24)),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
        Iff(
          operation.eq(
            Const(LoadStoreUnit.operation.lhu, width: operation.width),
          ),
          then: [
            When(
              [
                Iff(
                  lowAddress.eq(Const(0, width: lowAddress.width)),
                  then: [
                    outputData.assign(
                      Const(0, width: 16).cat(memData.part(15, 0)),
                    ),
                  ],
                ),
                Iff(
                  lowAddress.eq(Const(2, width: lowAddress.width)),
                  then: [
                    outputData.assign(
                      Const(0, width: 16).cat(memData.part(31, 16)),
                    ),
                  ],
                ),
              ],
              orElse: [
                addressMisaligned.assign(Const(1)),
              ],
            ),
          ],
        ),
        Iff(
          operation.eq(
            Const(LoadStoreUnit.operation.sb, width: operation.width),
          ),
          then: [
            When(() {
              final iffs = <Iff>[];
              for (var i = 0; i < 4; ++i) {
                if (i == 0) {
                  iffs.add(
                    Iff(
                      lowAddress.eq(Const(i, width: lowAddress.width)),
                      then: [
                        outputData.assign(
                          memData.part(31, 8).cat(regData.part(7, 0)),
                        ),
                      ],
                    ),
                  );
                } else if (i == 1) {
                  iffs.add(
                    Iff(
                      lowAddress.eq(Const(i, width: lowAddress.width)),
                      then: [
                        outputData.assign(
                          memData
                              .part(31, 16)
                              .cat(regData.part(7, 0))
                              .cat(memData.part(7, 0)),
                        ),
                      ],
                    ),
                  );
                } else if (i == 2) {
                  iffs.add(
                    Iff(
                      lowAddress.eq(Const(i, width: lowAddress.width)),
                      then: [
                        outputData.assign(
                          memData
                              .part(31, 24)
                              .cat(regData.part(7, 0))
                              .cat(memData.part(15, 0)),
                        ),
                      ],
                    ),
                  );
                } else {
                  iffs.add(
                    Iff(
                      lowAddress.eq(Const(i, width: lowAddress.width)),
                      then: [
                        outputData.assign(
                          regData.part(7, 0).cat(memData.part(23, 0)),
                        ),
                      ],
                    ),
                  );
                }
              }
              return iffs;
            }()),
          ],
        ),
        Iff(
          operation.eq(
            Const(LoadStoreUnit.operation.sh, width: operation.width),
          ),
          then: [
            When(
              [
                Iff(
                  lowAddress.eq(Const(0, width: lowAddress.width)),
                  then: [
                    outputData.assign(
                      memData.part(31, 16).cat(regData.part(15, 0)),
                    ),
                  ],
                ),
                Iff(
                  lowAddress.eq(Const(2, width: lowAddress.width)),
                  then: [
                    outputData.assign(
                      regData.part(31, 16).cat(memData.part(15, 0)),
                    ),
                  ],
                ),
              ],
              orElse: [
                addressMisaligned.assign(Const(1)),
              ],
            ),
          ],
        ),
        Iff(
          operation.eq(
            Const(LoadStoreUnit.operation.sw, width: operation.width),
          ),
          then: [
            When(
              [
                Iff(
                  lowAddress.eq(Const(0, width: lowAddress.width)),
                  then: [outputData.assign(regData)],
                ),
              ],
              orElse: [
                addressMisaligned.assign(Const(1)),
              ],
            ),
          ],
        ),
      ]),
    ]);
  }

  late final Var addressMisaligned;
  late final Var outputData;

  static final operation = (
    lb: int.parse('0000', radix: 2),
    lh: int.parse('0001', radix: 2),
    lw: int.parse('0010', radix: 2),
    lbu: int.parse('0100', radix: 2),
    lhu: int.parse('0101', radix: 2),
    sb: int.parse('1000', radix: 2),
    sh: int.parse('1001', radix: 2),
    sw: int.parse('1010', radix: 2),
  );
}
