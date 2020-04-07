# TDS Deadlock Demo

This repo recreates deadlock issues that are occurring
when setting `set_allow_snapshot_isolation: :on` and running tests with `async: true`.

## To recreate

  1. Install dependencies with `mix deps.get`
  1. Run this docker container: `mcr.microsoft.com/mssql/server:2019-latest` (it may happen with earlier versions as well)
  1. Run `mix test`

## Errors

The errors are intermittent, but here is an example of the deadlock errors I'm seeing

```
$ mix test

07:18:28.737 [debug] (Tds.Info) Line 1 (Class 0) SNAPSHOT ISOLATION is always enabled in this database.

07:18:28.812 [info]  Already up
..................................

  1) test POST /users/reset_password does not send reset password token if email is invalid (DemoMssqlWeb.UserResetPasswordControllerTest)
     test/demo_mssql_web/controllers/user_reset_password_controller_test.exs:33
     ** (Tds.Error) Line 1 (Error 1205): Transaction (Process ID 55) was deadlocked on lock resources with another process and has been chosen as the deadlock victim. Rerun the transaction.
     code: assert Repo.all(Accounts.UserToken) == []
     stacktrace:
       (ecto_sql 3.4.2) lib/ecto/adapters/sql.ex:612: Ecto.Adapters.SQL.raise_sql_call_error/1
       (ecto_sql 3.4.2) lib/ecto/adapters/sql.ex:545: Ecto.Adapters.SQL.execute/5
       (ecto 3.4.0) lib/ecto/repo/queryable.ex:192: Ecto.Repo.Queryable.execute/4
       (ecto 3.4.0) lib/ecto/repo/queryable.ex:17: Ecto.Repo.Queryable.all/3
       test/demo_mssql_web/controllers/user_reset_password_controller_test.exs:41: (test)



  2) test GET /users/confirm/:token confirms the given token once (DemoMssqlWeb.UserConfirmationControllerTest)
     test/demo_mssql_web/controllers/user_confirmation_controller_test.exs:59
     ** (Tds.Error) Line 1 (Error 1205): Transaction (Process ID 57) was deadlocked on lock resources with another process and has been chosen as the deadlock victim. Rerun the transaction.
     code: conn = get(conn, Routes.user_confirmation_path(conn, :confirm, token))
     stacktrace:
       (ecto_sql 3.4.2) lib/ecto/adapters/sql.ex:612: Ecto.Adapters.SQL.raise_sql_call_error/1
       (ecto_sql 3.4.2) lib/ecto/adapters/sql.ex:545: Ecto.Adapters.SQL.execute/5
       (ecto 3.4.0) lib/ecto/multi.ex:606: Ecto.Multi.apply_operation/4
       (ecto 3.4.0) lib/ecto/multi.ex:585: Ecto.Multi.apply_operation/5
       (elixir 1.10.2) lib/enum.ex:2111: Enum."-reduce/3-lists^foldl/2-0-"/3
       (ecto 3.4.0) lib/ecto/multi.ex:569: anonymous fn/5 in Ecto.Multi.apply_operations/5
       (ecto_sql 3.4.2) lib/ecto/adapters/sql.ex:894: anonymous fn/3 in Ecto.Adapters.SQL.checkout_or_transaction/4
       (db_connection 2.2.1) lib/db_connection.ex:1427: DBConnection.run_transaction/4
       (ecto 3.4.0) lib/ecto/repo/transaction.ex:20: Ecto.Repo.Transaction.transaction/4
       (demo_mssql 0.1.0) lib/demo_mssql/accounts.ex:277: DemoMssql.Accounts.confirm_user/1
       (demo_mssql 0.1.0) lib/demo_mssql_web/controllers/user_confirmation_controller.ex:31: DemoMssqlWeb.UserConfirmationController.confirm/2
       (demo_mssql 0.1.0) lib/demo_mssql_web/controllers/user_confirmation_controller.ex:1: DemoMssqlWeb.UserConfirmationController.action/2
       (demo_mssql 0.1.0) lib/demo_mssql_web/controllers/user_confirmation_controller.ex:1: DemoMssqlWeb.UserConfirmationController.phoenix_controller_pipeline/2
       (phoenix 1.5.0-dev) lib/phoenix/router.ex:352: Phoenix.Router.__call__/2
       (demo_mssql 0.1.0) lib/demo_mssql_web/endpoint.ex:1: DemoMssqlWeb.Endpoint.plug_builder_call/2
       (demo_mssql 0.1.0) lib/demo_mssql_web/endpoint.ex:1: DemoMssqlWeb.Endpoint.call/2
       (phoenix 1.5.0-dev) lib/phoenix/test/conn_test.ex:225: Phoenix.ConnTest.dispatch/5
       test/demo_mssql_web/controllers/user_confirmation_controller_test.exs:65: (test)

.

  3) test POST /users/reset_password sends a new reset password token (DemoMssqlWeb.UserResetPasswordControllerTest)
     test/demo_mssql_web/controllers/user_reset_password_controller_test.exs:22
     ** (Tds.Error) Line 1 (Error 1205): Transaction (Process ID 61) was deadlocked on lock resources with another process and has been chosen as the deadlock victim. Rerun the transaction.
     code: assert Repo.get_by!(Accounts.UserToken, user_id: user.id).context == "reset_password"
     stacktrace:
       (ecto_sql 3.4.2) lib/ecto/adapters/sql.ex:612: Ecto.Adapters.SQL.raise_sql_call_error/1
       (ecto_sql 3.4.2) lib/ecto/adapters/sql.ex:545: Ecto.Adapters.SQL.execute/5
       (ecto 3.4.0) lib/ecto/repo/queryable.ex:192: Ecto.Repo.Queryable.execute/4
       (ecto 3.4.0) lib/ecto/repo/queryable.ex:17: Ecto.Repo.Queryable.all/3
       (ecto 3.4.0) lib/ecto/repo/queryable.ex:120: Ecto.Repo.Queryable.one!/3
       test/demo_mssql_web/controllers/user_reset_password_controller_test.exs:30: (test)

     The following output was logged:
     07:18:31.644 [error] GenServer #PID<0.505.0> terminating
     ** (RuntimeError) Ecto SQL sandbox transaction was already committed/rolled back.

     The sandbox works by running each test in a transaction and closing thetransaction afterwards. However, the transaction has already terminated.Your test code is likely committing or rolling back transactions manually,either by invoking procedures or running custom SQL commands.

     One option is to manually checkout a connection without a sandbox:

         Ecto.Adapters.SQL.Sandbox.checkout(repo, sandbox: false)

     But remember you will have to undo any database changes performed by such tests.

         (ecto_sql 3.4.2) lib/ecto/adapters/sql/sandbox.ex:517: Ecto.Adapters.SQL.Sandbox.pre_checkin/4
         (db_connection 2.2.1) lib/db_connection/ownership/proxy.ex:221: DBConnection.Ownership.Proxy.pool_done/5
         (stdlib 3.10) gen_server.erl:637: :gen_server.try_dispatch/4
         (stdlib 3.10) gen_server.erl:711: :gen_server.handle_msg/6
         (stdlib 3.10) proc_lib.erl:249: :proc_lib.init_p_do_apply/3
     Last message: {:DOWN, #Reference<0.1969097885.731119618.19505>, :process, #PID<0.504.0>, :shutdown}
     07:18:36.619 [error] Tds.Protocol (#PID<0.361.0>) disconnected: ** (DBConnection.TransactionError) transaction is not started

...07:18:40.372 [error] GenServer #PID<0.561.0> terminating
** (RuntimeError) Ecto SQL sandbox transaction was already committed/rolled back.

The sandbox works by running each test in a transaction and closing thetransaction afterwards. However, the transaction has already terminated.Your test code is likely committing or rolling back transactions manually,either by invoking procedures or running custom SQL commands.

One option is to manually checkout a connection without a sandbox:

    Ecto.Adapters.SQL.Sandbox.checkout(repo, sandbox: false)

But remember you will have to undo any database changes performed by such tests.

    (ecto_sql 3.4.2) lib/ecto/adapters/sql/sandbox.ex:517: Ecto.Adapters.SQL.Sandbox.pre_checkin/4
    (db_connection 2.2.1) lib/db_connection/ownership/proxy.ex:221: DBConnection.Ownership.Proxy.pool_done/5
    (stdlib 3.10) gen_server.erl:637: :gen_server.try_dispatch/4
    (stdlib 3.10) gen_server.erl:711: :gen_server.handle_msg/6
    (stdlib 3.10) proc_lib.erl:249: :proc_lib.init_p_do_apply/3
Last message: {:DOWN, #Reference<0.1969097885.731119617.22623>, :process, #PID<0.560.0>, :shutdown}


  4) test POST /users/confirm sends a new confirmation token (DemoMssqlWeb.UserConfirmationControllerTest)
     test/demo_mssql_web/controllers/user_confirmation_controller_test.exs:22
     ** (Tds.Error) Line 1 (Error 1205): Transaction (Process ID 53) was deadlocked on lock resources with another process and has been chosen as the deadlock victim. Rerun the transaction.
     code: assert Repo.get_by!(Accounts.UserToken, user_id: user.id).context == "confirm"
     stacktrace:
       (ecto_sql 3.4.2) lib/ecto/adapters/sql.ex:612: Ecto.Adapters.SQL.raise_sql_call_error/1
       (ecto_sql 3.4.2) lib/ecto/adapters/sql.ex:545: Ecto.Adapters.SQL.execute/5
       (ecto 3.4.0) lib/ecto/repo/queryable.ex:192: Ecto.Repo.Queryable.execute/4
       (ecto 3.4.0) lib/ecto/repo/queryable.ex:17: Ecto.Repo.Queryable.all/3
       (ecto 3.4.0) lib/ecto/repo/queryable.ex:120: Ecto.Repo.Queryable.one!/3
       test/demo_mssql_web/controllers/user_confirmation_controller_test.exs:30: (test)

     The following output was logged:
     07:18:39.118 [error] GenServer #PID<0.555.0> terminating
     ** (RuntimeError) Ecto SQL sandbox transaction was already committed/rolled back.

     The sandbox works by running each test in a transaction and closing thetransaction afterwards. However, the transaction has already terminated.Your test code is likely committing or rolling back transactions manually,either by invoking procedures or running custom SQL commands.

     One option is to manually checkout a connection without a sandbox:

         Ecto.Adapters.SQL.Sandbox.checkout(repo, sandbox: false)

     But remember you will have to undo any database changes performed by such tests.

         (ecto_sql 3.4.2) lib/ecto/adapters/sql/sandbox.ex:517: Ecto.Adapters.SQL.Sandbox.pre_checkin/4
         (db_connection 2.2.1) lib/db_connection/ownership/proxy.ex:221: DBConnection.Ownership.Proxy.pool_done/5
         (stdlib 3.10) gen_server.erl:637: :gen_server.try_dispatch/4
         (stdlib 3.10) gen_server.erl:711: :gen_server.handle_msg/6
         (stdlib 3.10) proc_lib.erl:249: :proc_lib.init_p_do_apply/3
     Last message: {:DOWN, #Reference<0.1969097885.731119619.22578>, :process, #PID<0.554.0>, :shutdown}

.........................................................

Finished in 12.0 seconds
99 tests, 4 failures
```
