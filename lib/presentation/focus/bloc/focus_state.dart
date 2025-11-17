class FocusState {
  final bool isLoading;
  final String? errorMessage;

  const FocusState({this.isLoading = false, this.errorMessage});

  FocusState copyWith({bool? isLoading, String? errorMessage}) {
    return FocusState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
    );
  }
}
