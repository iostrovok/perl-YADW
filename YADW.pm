package YADW;

use strict;
use warnings;

use DBI;
use SQL::Abstract::Limit;
use Data::Dumper;

our $VERSION = '0.01';

=head1 NAME

C<YADW> is "Yet Another DBI Wrapper", class which makes easy frequent actions with DBI.
It use "AUTOLOAD", but creates "refsub" during first call and don't use "AUTOLOAD" for next times.

=head1 SYNOPSYS

    my $dbh = new DBI(...);
    my $dby = new YADW( dbh => $dbh );

    OR

    my $dby = new YADW( config_line => 'dbi:DriverName:database=singers/127.0.0.1/6543/root/password' );
    foreach ( @{$dby->get_public_houses_list({ type => 'hotel' })} ) {
        print $_->{id}, ':', $_->{title}, "\n";
    }

    foreach ( @{$dby->simple("SELECT o.name, h.title FROM public.houses h, public.owner o WHERE h.type = 'hotel' AND o.id = h.owner_id")} ) {
        print $_->{name}, ':', $_->{title}, "\n";
    }

    # update
    $dby->update_public_houses_list({ owner => 'JOHN', address => 'Abbey Road, 1' }, { id => 223345 });

    # delete
    $dby->delete_public_houses_list({ id => 99908 });

    # update or insert
    $dby->uoi_public_houses_list({ owner => 'POUL', address => 'Abbey Road, 1' }, { type => 'house', owner => 'Martin', });

    # find or insert
    $dby->foi_public_houses_list({ address => 'Abbey Road, 1' }, { type => 'house', owner => 'Martin', });

    # update or insert
    $dby->uoi_public_houses_list({ owner => 'POUL', address => 'Abbey Road, 1' }, { type => 'house', owner => 'Martin', });

    # count
    print "Poul has ", $dby->count_public_houses_list({ owner => 'POUL', type => 'house' }), " houses";

=head1 METHODS

=head2 C<new>

It creates new YADW object.

    my $dbh = new DBI(...);
    my $dby = new YADW( dbh => $dbh );

    OR

    my $dby = new YADW( config_line => 'dbi:DriverName:database=singers/127.0.0.1/6543/root/password' );

=head3 Params


=head4 bdh

instanse DBI.

=head4 config_line

it's line which contents data for connect to database if you not use 'bdh' parameter. 
It includes source source, host, port and password connected by slashes.

Example: "dbi:Pg:mydatabase=singers/127.0.0.1/6543/root/password"

=head4 config

it's like "config_line" but it's HASHREF

=head4 attr_line

    it contents data for addition "%attr" for database. It's used only with "config_line" parameter.
    The "attr_line" parameter can be used to alter the default settings of PrintError, RaiseError, 
    AutoCommit, and other attributes connected by slashes.

=head3 Example
    "RaiseError/0/PrintError/1/AutoCommit/1/PrintWarn/1"

=head4 data_attr
    it likes attr_line but it's hash ref

=head3 Example

    {
        RaiseError            => 0,
        PrintError            => 1,
        AutoCommit            => 1,
        PrintWarn            => 1,
    }

=head2 L<get_[schema]_[table]> or L<all_[schema]_[table]>

Returns array ref of hash. Includs all columns for each line.

=head3 Params

get_[schema]_[table]([ $where, [ \@order, [ $rows, [ $offset ], [ $dialect ] ] ] ] )

Same as SQL::Abstract::Limit::where.

=head3 Example

    schema: "public"
    table: "singer"

    use Data::Dumper;
    print Dumper $dby->get_public_singer( { band => 'The Beatles' }, ['sname'], 0, 3 );

    [
        { sname => 'Harrison',    name => 'George',    band => 'The Beatles', id => 453 },
        { sname => 'Lennon',    name => 'John',        band => 'The Beatles', id => 15 },
        { sname => 'McCartney',    name => 'Paul',        band => 'The Beatles', id => 172 },
    ]

=head2 L<get_[table]> or L<all_[table]>

Same as get_[schema]_[table], if you use schema or schema_per methods

=head3 Params

Same as get_[schema]_[table].

=head3 Example

    schema: "public"
    table: "singer"

    $dby->get_public_singer( { band => 'The Beatles' }, ['sname'], 0, 3 );

    [
        { sname => 'Harrison',    name => 'George',    band => 'The Beatles', id => 453 },
        { sname => 'Lennon',    name => 'John',        band => 'The Beatles', id => 15 },
        { sname => 'McCartney',    name => 'Paul',        band => 'The Beatles', id => 172 },
    ]

=head2 L<cols_[schema]_[table]>

Same as get_[schema]_[table], but you have to set list of returned columns  into first parameter.

=head3 Params

cols_[schema]_[table]( columns, [ $where, [ \@order, [ $rows, [ $offset ], [ $dialect ] ] ] ] )

=head3 Example

    schema: "public"
    table: "singer"

    $dby->cols_public_singer( ['sname', 'name' ], { band => 'The Beatles' }, ['sname'], 0, 3 );

    [
        { sname => 'Harrison',    name => 'George', },
        { sname => 'Lennon',    name => 'John',      },
        { sname => 'McCartney',    name => 'Paul',      },
    ]

=head2 L<col_[schema]_[table]>

Same as cols_[schema]_[table], but you have to set only ONE column.
Returns simple list (not reference).

=head3 Params

col_[schema]_[table]( column, [ $where, [ \@order, [ $rows, [ $offset ], [ $dialect ] ] ] ] )

=head3 Example

    schema: "public"
    table: "singer"

    $dby->col_public_singer( 'name', { band => 'The Beatles' }, ['sname'], 0, 3 );

    (
        'George',
        'John',
        'Paul',
    )


=head2 L<findorcreate_[schema]_[table]>,  L<findorinsert_[schema]_[table]>, L<foc_[schema]_[table]>, L<foi_[schema]_[table]>

Makes two operations:
- finds record
- create it if has found nothing

Returns boolean.

=head3 Params

foi_[schema]_[table]( $data, $where)

=head3 Example

    schema: "public"
    table: "singer"

    $dby->doit('delete from public.singer'); # Clean table
    $dby->foi_public_singer( { name => 'George', }, { sname => 'Harrison', band => 'The Beatles' });

    { sname => 'Harrison',    name => 'George',    band => 'The Beatles', id => 1844 },


=head2 L<schema_per>

    Sets permanent schema name.

=head3 Params

    Schema name.

=head2 L<schema>

    Sets schema schema name for next single action.
    It has more higher priority than schema_per method.

=head3 Params

    Schema name

=head2 L<getrow_[schema]_[table]> or L<row_[schema]_[table]>

    Same as "get_[schema]_[table]", but always returns hashref of first record.

=head3 Example

    schema: "public"
    table: "singer"

    $dby->getrow_public_singer( { band => 'The Beatles' }, ['sname'], 0, 3 );

    { sname => 'Harrison',    name => 'George',    band => 'The Beatles', id => 453 },

=head2 L<count_[schema]_[table]> or L<count_[table]>

    Returns count records with your conditions.
    To use count_[table] you have to use schema or schema_per.

=head3 Params

    Same as SQL::Abstract::Limit::where.

=head3 Example

    schema: "public"
    table: "singer"

    my $singers = $dby->count_public_singer({ band => 'The Beatles' }); 
    # $singers == 4

=head2 L<update_[schema]_[table]> or L<update_[table]>

    Updates recods. To use update_[table] you have to use schema or schema_per.

=head3 Params

    first - hashref which includes update data.
    second - hashref same as first param from SQL::Abstract::Limit::where.

=head3 Example

    schema: "public"
    table: "singer"

    $dby->update_public_singer({ id => 1 }, { band => 'The Beatles' });
    print Dumper $dby->get_public_singer({ band => 'The Beatles' });

    prints:
    [
        { sname => 'Harrison',    name => 'George',    band => 'The Beatles', id => 1 },
        { sname => 'Lennon',    name => 'John',        band => 'The Beatles', id => 1 },
        { sname => 'McCartney',    name => 'Paul',        band => 'The Beatles', id => 1 },
        { sname => 'Starr',    name => 'Ringo',    band => 'The Beatles', id => 1 },
    ]

=head1 SQL-line functions

=head2 L<doit>

    like $dbh->do()

=head3 Params

    SQL line, SQL params

=head3 Example

    schema: "public"
    table: "singer"

    $dby->doit('delete from public.singer WHERE sname = ? AND name = ?', 'Harrison', 'George');

    It deletes record { sname => 'Harrison', name => 'George', band => 'The Beatles', id => 1 },

=head2 L<simple>

    like $dbh->get()

=head3 Params

    SQL line, SQL params

=head3 Example

    schema: "public"
    table: "singer"


    use Data::Dumper;
    print Dumper $dby->get_public_singer('select * from public.singer WHERE sname = ? AND name = ?', 'Harrison', 'George);

    [
        { sname => 'Harrison',    name => 'George',    band => 'The Beatles', id => 1 },
    ]

=head2 L<getrow_simple>, L<row_simple>

    like $dbh->row()

=head3 Params

    SQL line, SQL params

=head3 Example

    schema: "public"
    table: "singer"

    use Data::Dumper;
    print Dumper $dby->get_public_singer('select * from public.singer WHERE sname = ? AND name = ?', 'Harrison', 'George);

    { sname => 'Harrison', name => 'George', band => 'The Beatles', id => 1 },

=head1 Accessors

=head2 L<dbh>

    Returns DBI object

=head3 Params

    none

=head3 Example

    print UNIVERSAL::isa( $dby->dbh, 'DBI') ? 'Yes' : 'No';

    # prints "Yes"

=cut

our $AUTOLOAD;

my %ACTIONS = map {( $_ => 1 )} qw[
    all col cols count delete findorcreate findorinsert foc foi get getfun getrow insert ivalue procedure row uoi uoc update updateorcreate updateorinsert value
];

sub choose_dirver {
    my ( $self, $DriverLine ) = @_;
    return $DriverLine unless $DriverLine =~ /\:Pg/i;

    my @drivers = DBI->available_drivers;

    if ( grep { $_ eq 'Pg' } @drivers ) {
        $DriverLine = 'dbi:Pg:db';
    } elsif ( grep { $_ eq 'PgPP' } @drivers ) {
        $DriverLine = 'dbi:PgPP:db';
    } else {
        die "No available_drivers!"
    }
}

=head1 new


=cut

sub new {
    my $class = shift;

    my $self = bless {
        dbh                => undef,
        data_attr        => {},
        RETURNING        => {},
        RETURNING_LIST    => [],
        is_return        => 0,
        is_return_inner    => 0,
        to_utf8            => 0,
        debug            => 0,
        is_die            => 1,
        last_sub        => '',
        limit_dialect    => '',
        _schema_per        => '',
        _schema            => '',
        @_,
    }, $class;

    $self->{debug} && $self->alert_log("Start Moduls::DBI");

    unless ( $self->{dbh} ) {
        if ( $self->{config_line} ) {
            $self->{config} = {};
            $self->{config_line} =~ s{^/+}{};
            @{$self->{config}}{qw[ source host port user password ]} = split(/\/+/, $self->{config_line}, 5 );
        }

        if ( $self->{attr_line} ) {
            $self->{data_attr} = {};
            $self->{config_line} =~ s{^/+}{};
            %{$self->{data_attr}} = ( split(/\/+/, $self->{attr_line} ));
        }

        die 'No defined config params!' unless exists $self->{config} && ref $self->{config} && %{$self->{config}};
        $self->init_dbi_connection();
    }

    $self->{sql} = new SQL::Abstract::Limit( limit_dialect => ( $self->{limit_dialect} || $self->{dbh} ) );

    return $self;
}

# RETURNING setters & getters
sub set_returning    { $_[0]->{is_return} = 1; }
sub clean_returning { $_[0]->{RETURNING} = {}; $_[0]->{RETURNING_LIST} = []; $_[0]->{is_return} = 0; }
sub returning        { $_[0]->{RETURNING}; }
sub returning_list    { $_[0]->{RETURNING_LIST}; }

sub schema_per        { $_[0]->{_schema_per} = "$_[1]"; }
sub schema            { $_[0]->{_schema} = "$_[1]"; }
sub clean_schema    { $_[0]->{_schema_per} = $_[0]->{_schema} = ''; }

sub error_log {
    my $self = shift;
    print STDERR join("\n", @_), "\n";
}

sub alert_log {
    my $self = shift;
    return unless $self->{debug};
    die "Please redifind this function in your code.";
}

=head1
=cut

sub dbh { $_[0]->{dbh}; }
sub init_dbi_connection {
    # Init database connect
    my $self = shift;
    my $config = $self->{config};

    undef $self->{dbh};

    my $data_attr = {
        RaiseError            => 0,
        PrintError            => 1,
        AutoCommit            => 1,
        PrintWarn            => 1,
        %{$self->{data_attr}},
    };

    my $DriverLine = $self->choose_dirver( $config->{driver} );
    my $data_source = $DriverLine .'='. $config->{source} .';host='.
        $config->{host} .';port='. $config->{port};

    eval {
        local $SIG{ALRM} = sub { die "Die by alarm\n" } if $DriverLine eq 'dbi:PgPP:db';
        alarm 10;
        $self->{dbh} = DBI->connect_cached( $data_source, $config->{user}, $config->{password}, $data_attr )
            or die DBI->errstr;
        alarm 0;
    };
    if ( $@ ) { $self->error_log($@); die $@; }
}

sub doit {
    my $self = shift;
    my $slq_line = shift;
    $self->{last_sub} = "doit";

    my @out = ();
    eval {
        my $sth = $self->{dbh}->prepare($slq_line) or die DBI->errstr;
        $sth->execute( @_ ) or die DBI->errstr;
    };

    if ( $@ ) {
        $self->send_log( $@, $slq_line, Dumper(\@_) );
        die $@;
    }
}

sub simple {
    my $self = shift;
    my $slq_line = shift;
    $self->{last_sub} = "simple";

    my @out = ();
    eval {
        my $sth = $self->{dbh}->prepare($slq_line) or die DBI->errstr;
        $sth->execute( @_ ) or die DBI->errstr;
        while ( my $hash_ref = $sth->fetchrow_hashref ) {
            push ( @out, $hash_ref );
        }
    };

    if ( $@ ) {
        $self->send_log( $@, $slq_line, Dumper(\@_) );
        die $@;
    }
    return [@out];
}

sub _is_fullhashref { $_[0] && ref $_[0] eq 'HASH' && %{$_[0]} ? 1 : 0 }

sub row_simple { return shift->getrow_simple(@_); }

sub getrow_simple {
    my $self = shift;
    my $slq_line = shift;
    $self->{last_sub} = "getrow_simple";

    my $out;
    eval {
        my $sth = $self->{dbh}->prepare($slq_line) or die DBI->errstr;
        $sth->execute( @_ ) or die DBI->errstr;
        $out = $sth->fetchrow_hashref;
    };

    if ( $@ ) {
        $self->send_log( $@, $slq_line, Dumper(\@_) );
        die $@;
    }
    return $out;
}

sub DESTROY  {}
sub AUTOLOAD {
    my $self  = shift;
    my( $act, $sm_table, $slq_line, @bind, @out, $sth, $err, $table );

    my $full_name = $AUTOLOAD;
    $AUTOLOAD =~ s/.*:://;

    my $schema = $self->{_schema} || $self->{_schema_per};

    if ( $schema ) {
        ( $act, $sm_table ) = $AUTOLOAD =~ m/^([^_]+)_(.+)/gios;
    }
    else {
        ( $act, $schema, $sm_table ) = $AUTOLOAD =~ m/^([^_]+)_([^_]+)_(.+)/gios;
    }

    if ( exists $ACTIONS{$act} ) {

        $table =  ($self->{_schema} || $self->{_schema_per}) ? $sm_table : $schema .'.'. $sm_table ;
        $self->_include_sub ( $full_name, $act, $table );

        my $name = $self->{last_sub} = "$AUTOLOAD";
        return $self->$name(@_);
    }

    $self->error_log('BAD ACTION:: "'. $act, '", BAD ACTION:: "'. join('#', @_), '"' );
    die 'BAD ACTION:: "'. $act, '", BAD ACTION:: "'. join('#', @_), '"';
}

sub _clean {
    $_[0]->{RETURNING} = {};
    $_[0]->{RETURNING_LIST} = [];
    $_[0]->{last_sub} = '';
}

sub table_name {
    my ( $self, $table ) = @_;

    my $s = $self->{_schema} || $self->{_schema_per};
    $self->{_schema} = '';

    return $s ? $s .'.'. $table : $table;
}

sub do_line_returning {
    my ( $self, $sub, $table ) = ( shift, shift, shift );

    my ( $slq_line, @bind ) = $self->{sql}->$sub( $table, @_ );
    $slq_line .= ' RETURNING * ' if $self->{is_return};

    my $sth = $self->{dbh}->prepare($slq_line) or die DBI->errstr;
    my $err = $sth->execute( @bind ) or die DBI->errstr;

    if ( $self->{is_return} ) {
        my @out;
        while ( my $hash_ref = $sth->fetchrow_hashref ) {
            push ( @out, $hash_ref );
        }
        $self->{RETURNING} = $out[0] || {};
        $self->{RETURNING_LIST} = [ @out ] ;
    }

    return $err;
}

sub _init_action {
    my ( $self, $name, $table_in, $full_name, $act ) = @_;
    $self->_clean(); 
    $self->{last_sub} = $name; 
    my $table = $self->table_name( $table_in );
    $self->{DEBUG} && warn(__PACKAGE__ ." INCLUDE => $full_name, $act, $table");
    return $self, $table;
}

sub _include_sub {
    my ( $self, $full_name, $act, $table_in ) = @_;

    no strict 'refs';

    my $name = $full_name;
    $name =~ s/.*:://;

    if ( $act eq 'all' ||  $act eq 'get' || $act eq 'cols' ) {
        return *$full_name = sub {
                my ( $self, $table ) = shift->_init_action( $self, $name, $table_in, $full_name, $act );
                return eval {
                    my ( $slq_line, @bind ) = $self->{sql}->select( $table, $act eq 'cols' ? ( @_ )  : ( ['*'], @_ ) );
                    my $sth = $self->{dbh}->prepare($slq_line) or die DBI->errstr;
                    $sth->execute( @bind ) or die DBI->errstr;

                    my @out;
                    while ( my $hash_ref = $sth->fetchrow_hashref ) {
                        push ( @out, $hash_ref );
                    }
                    return [ @out ];
                };
                die "SUB: $name, $@ " if $@;
            };
    }

    if ( $act eq 'col' ||  $act eq 'getfun' ) {
        return *$full_name = sub {
                my ( $self, $table ) = shift->_init_action( $self, $name, $table_in, $full_name, $act );
                return eval {
                    my ( $slq_line, @bind ) = $self->{sql}->select( $table, @_ );
                    my $sth = $self->{dbh}->prepare($slq_line) or die DBI->errstr;
                    $sth->execute( @bind ) or die DBI->errstr;

                    my @out;
                    while ( my @a = $sth->fetchrow_array ) {
                        push ( @out, @a );
                    }
                    return @out;
                };
                die "SUB: $name, $@ " if $@;
            };
    }

    if ( $act eq 'count' ) {
        *$full_name = sub {
                my ( $self, $table ) = shift->_init_action( $self, $name, $table_in, $full_name, $act );
                return eval {
                    my ( $slq_line, @bind ) = $self->{sql}->select( $table, ['count(*)'], @_ );
                    $self->{dbh}->selectrow_array( $slq_line, {}, @bind ) || 0;
                };
                die "SUB: $name, $@ " if $@;
            };
    }

    if ( $act eq 'getrow' || $act eq 'row' ) {
        return *$full_name = sub {
                my ( $self, $table ) = shift->_init_action( $self, $name, $table_in, $full_name, $act );
                my $hash_ref = eval {
                    my ( $slq_line, @bind ) = $self->{sql}->select( $table, ['*'], @_, '', 0, 1);
                    return $self->{dbh}->selectrow_hashref($slq_line, {}, @bind);
                };
                die "SUB: $name, $@ " if $@;
                return _is_fullhashref( $hash_ref ) ? $hash_ref : {};
            };
    }

    if ( $act eq 'update' ) {
        return *$full_name = sub {
                my ( $self, $table ) = shift->_init_action( $self, $name, $table_in, $full_name, $act );
                return eval {
                    $self->do_line_returning( 'update', $table, @_ );
                };
                die "SUB: $name, $@ " if $@;
            };
    }

    if ( $act eq 'insert' ) {
        return *$full_name = sub {
                my ( $self, $table ) = shift->_init_action( $self, $name, $table_in, $full_name, $act );
                return eval {
                    $self->do_line_returning( 'insert', $table, @_ );
                };
                die "SUB: $name, $@ " if $@;
            };
    }

    if ( $act eq 'delete' ) {
        return *$full_name = sub {
                my ( $self, $table ) = shift->_init_action( $self, $name, $table_in, $full_name, $act );
                return eval {
                    $self->do_line_returning( 'delete', $table, @_ );
                };
                die "SUB: $name, $@ " if $@;
            };
    }

    if ( $act eq 'procedure' ) {
        return *$full_name = sub {
                my ( $self, $table ) = shift->_init_action( $self, $name, $table_in, $full_name, $act );
                return eval {
                    my @bind = @{$_[0]} if $_[0] && ref $_[0] eq 'ARRAY';
                    my $slq_line = "select $table(". join(',', ( split('', '?' x scalar( @bind ) ) ) ) .") AS res ";
                    my $sth = $self->{dbh}->prepare($slq_line) or die "SUB: $name, ". DBI->errstr;
                    return ( $sth->execute( @bind ) || die "SUB: $name, ". DBI->errstr);
                };
                die "SUB: $name, $@ " if $@;
            };
    }

    if ( $act eq 'ivalue' ) {
        return *$full_name = sub {
                my ( $self, $table ) = shift->_init_action( $self, $name, $table_in, $full_name, $act );
                my @send = @_;
                my $value = 0;
                eval {
                    $send[0] = [$send[0]] unless ref $send[0] eq 'ARRAY';
                    my ( $slq_line, @bind ) = $self->{sql}->select( $table, @send );
                    ( $value ) = $self->{dbh}->selectrow_array( $slq_line, {}, @bind ) || 0;
                };
                die "SUB: $name, $@ " if $@;
                return int($value);
            };
    }

    if ( $act eq 'value' ) {
        return *$full_name = sub {
                my ( $self, $table ) = shift->_init_action( $self, $name, $table_in, $full_name, $act );
                my @send = @_;
                my $value;
                eval {
                    $send[0] = [$send[0]] unless ref $send[0] eq 'ARRAY';
                    my ( $slq_line, @bind ) = $self->{sql}->select( $table, @send );
                    ( $value ) = $self->{dbh}->selectrow_array( $slq_line, {}, @bind ) || undef;
                };
                die "SUB: $name, $@ " if $@;
                return $value;
            };
    }

    if ( $act eq 'findorcreate' or $act eq 'findorinsert' or $act eq 'foi' or $act eq 'foc' ) {
        return *$full_name = sub {
                my ( $self, $table ) = shift->_init_action( $self, $name, $table_in, $full_name, $act );
                return eval {
                    my ( $slq_line, @bind ) = $self->{sql}->select( $table, ['*'], $_[1], '', 0, 1);
                    my $hash_ref = $self->{dbh}->selectrow_hashref( $slq_line, {}, @bind );

                    return $hash_ref if _is_fullhashref( $hash_ref );
                    return $self->do_line_returning( 'insert', $table, { %{$_[1]}, %{$_[0]} } );
                };
                die "SUB: $name, $@ " if $@;
            };
    }

    if ( $act eq 'updateorcreate' or $act eq 'updateorinsert' or $act eq 'uoi' or $act eq 'uoc' ) {
        return *$full_name = sub {
                my ( $self, $table ) = shift->_init_action( $self, $name, $table_in, $full_name, $act );
                return eval {
                    my ( $slq_line, @bind ) = $self->{sql}->select( $table, [' count(*) as counters '], $_[1] );
                    my $count = $self->{dbh}->selectrow_array( $slq_line, {}, @bind ) || 0;

                    return $self->do_line_returning( 'update', $table, @_ ) if $count > 0;
                    return $self->do_line_returning( 'insert', $table, { %{$_[1]}, %{$_[0]} } );
                };
                die "SUB: $name, $@ " if $@;
            };
    }

}


1;

