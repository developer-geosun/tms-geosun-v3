import 'package:flutter_test/flutter_test.dart';

import 'package:tms_geosun/auth/domain/auth_models.dart';
import 'package:tms_geosun/core/http/api_error.dart';

void main() {
  test('mapLoginErrorCode відповідає кодам backend', () {
    expect(
      mapLoginErrorCode(
        const ApiException(
          statusCode: 403,
          code: 'EMAIL_NOT_VERIFIED',
          message: '',
        ),
      ),
      LoginErrorCode.emailNotVerified,
    );
    expect(
      mapLoginErrorCode(
        const ApiException(
          statusCode: 403,
          code: 'ACCOUNT_DISABLED',
          message: '',
        ),
      ),
      LoginErrorCode.accountDisabled,
    );
    expect(
      mapLoginErrorCode(
        const ApiException(statusCode: 403, code: 'USER_DELETED', message: ''),
      ),
      LoginErrorCode.userDeleted,
    );
    expect(
      mapLoginErrorCode(const ApiException(statusCode: 401, message: '')),
      LoginErrorCode.error401,
    );
    expect(
      mapLoginErrorCode(const ApiException(statusCode: 403, message: '')),
      LoginErrorCode.error403,
    );
    expect(
      mapLoginErrorCode(const ApiException(statusCode: 500, message: '')),
      LoginErrorCode.generic,
    );
  });
}
